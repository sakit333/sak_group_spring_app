#!/bin/bash

set -e

LOGFILE="build-and-push.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "Script started at $(date)"

# Config - change these!
DOCKER_USERNAME="sakit333"
DOCKER_PASSWORD="your_dockerhub_password_here"
IMAGE_NAME="spring-app"
TAG="latest"
FULL_IMAGE_NAME="$DOCKER_USERNAME/$IMAGE_NAME:$TAG"

# Function to run commands with sudo non-interactively
run_sudo() {
    if [ "$EUID" -ne 0 ]; then
        sudo -n "$@"
    else
        "$@"
    fi
}

echo "Checking if docker is installed..."

if ! command -v docker &> /dev/null
then
    echo "Docker not found. Installing Docker..."

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "Cannot detect OS. Exiting."
        exit 1
    fi

    if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
        run_sudo apt-get update -y
        run_sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | run_sudo apt-key add -
        run_sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        run_sudo apt-get update -y
        run_sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io
    elif [[ "$OS" == "rhel" || "$OS" == "centos" || "$OS" == "fedora" ]]; then
        run_sudo yum install -y yum-utils
        run_sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        run_sudo yum install -y docker-ce docker-ce-cli containerd.io
        run_sudo systemctl start docker
        run_sudo systemctl enable docker
    else
        echo "Unsupported OS: $OS"
        exit 1
    fi

    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

# Start docker service if not running
if ! systemctl is-active --quiet docker; then
    echo "Starting Docker service..."
    run_sudo systemctl start docker
fi

# Docker login non-interactive
echo "Logging in to Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

# Build docker image
echo "Building Docker image $FULL_IMAGE_NAME"
docker build -t $FULL_IMAGE_NAME .

# Push image
echo "Pushing Docker image to Docker Hub"
docker push $FULL_IMAGE_NAME

echo "Script finished at $(date)"
echo "Logs saved to $LOGFILE"
