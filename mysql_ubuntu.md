# ✅ PROCEDURE: MySQL 8.0.42 on Ubuntu 24.04 (EC2)

---

## 🟩 STEP 1: SSH into EC2 Instance

```bash
ssh -i /path/to/key.pem ubuntu@<EC2_PUBLIC_IP>
```

---

## 🟩 STEP 2: Update System & Install MySQL

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install mysql-server -y
```

---

## 🟩 STEP 3: Secure the Root User (Password Login)

Login to MySQL (as system user):

```bash
sudo mysql
```

Inside MySQL prompt:

```sql
-- Enable password login for root@localhost
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '1234';

-- Create a remote root user (for any IP)
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Apply changes
FLUSH PRIVILEGES;
EXIT;
```

---

## 🟩 STEP 4: Allow Remote Connections in MySQL Config

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

Find:

```
bind-address = 127.0.0.1
```

Change to:

```
bind-address = 0.0.0.0
```

Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`)

Then restart MySQL:

```bash
sudo systemctl restart mysql
```
---

## 🟩 OPTIONAL: Spring Boot Configuration

```properties
spring.datasource.url=jdbc:mysql://<EC2_PUBLIC_IP>:3306/your_db
spring.datasource.username=root
spring.datasource.password=1234
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

spring.jpa.hibernate.ddl-auto=update
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
```

---

