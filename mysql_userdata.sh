#!/bin/bash

# Update system
apt update && apt upgrade -y

# Install MySQL server
DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

# Configure MySQL root users and allow remote access
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '1234';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Allow remote connections by changing bind-address
sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart MySQL service
systemctl restart mysql

echo "Mysql is installed successfully"
echo "Do modification in spring app in that application.properties"
echo "spring.datasource.url=jdbc:mysql://<EC2_PUBLIC_IP>:3306/your_db"
echo "Script Done By @sak_shetty"
