#!/bin/bash

set -e

handle_error() {
    echo "❌  Error occurred during: $1" | tee -a install_log.txt
    exit 1
}

echo "🔧  Starting installation of Jenkins, Maven, and MySQL on Ubuntu..." | tee install_log.txt

# Update package list
echo "📦  Updating package list..." | tee -a install_log.txt
sudo apt update || handle_error "apt update"

# Install OpenJDK 17
echo "☕  Installing OpenJDK 17..." | tee -a install_log.txt
sudo apt install -y openjdk-17-jdk || handle_error "installing OpenJDK 17"
java -version || handle_error "verifying Java installation"

# Install Maven
echo "📦  Installing Maven..." | tee -a install_log.txt
sudo apt install -y maven || handle_error "installing Maven"
mvn -version || handle_error "verifying Maven installation"

# Install MySQL Server
echo "🛢️  Installing MySQL Server..." | tee -a install_log.txt
sudo apt install -y mysql-server || handle_error "installing MySQL Server"
sudo mysql_secure_installation || handle_error "securing MySQL"

# Install Jenkins
echo "🧩  Installing Jenkins..." | tee -a install_log.txt
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key || handle_error "adding Jenkins key"
sudo echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" |     sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null || handle_error "adding Jenkins repo"
sudo apt update || handle_error "apt update after adding Jenkins repo"
sudo apt install -y jenkins || handle_error "installing Jenkins"
sudo systemctl start jenkins || handle_error "starting Jenkins"
sudo systemctl enable jenkins || handle_error "enabling Jenkins"

echo "✅  Installation completed successfully!" | tee -a install_log.txt
echo "🔑  Jenkins is running on port 8080. Access it via: http://localhost:8080" | tee -a install_log.txt

# Create MySQL user and database
echo "🧑 <200d>💻  Creating MySQL user and database..." | tee -a install_log.txt
sudo mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS  Teacher;
CREATE USER IF NOT EXISTS 'springstudent'@'localhost' IDENTIFIED BY 'Springstudent@123';
GRANT ALL PRIVILEGES on Teacher.* to springstudent@localhost;
FLUSH PRIVILEGES;
EOF

if [ $? -ne 0 ]; then
    handle_error "creating MySQL user and database"
fi
echo "✅  MySQL user and database created successfully!" | tee -a install_log.txt

#Install Unzip
echo "☕  Installing Unzip..."
sudo apt install -y  unzip  || handle_error "installing dependencies"
unzip -v || handle_error "verifying Unzip installation"



# Create SonarQube user
echo "👤  Creating SonarQube user..."
sudo useradd -r -s /bin/false sonarqube || echo "SonarQube user may already exist"



# Download SonarQube
SONAR_VERSION="10.2.0.77647"
echo "⬇️ Downloading SonarQube ${SONAR_VERSION}..."
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip || handle_error "downloading SonarQube"


sudo rm -rf /opt/sonarqube

echo "📂  Extracting SonarQube..."
unzip sonarqube-${SONAR_VERSION}.zip || handle_error "unzipping SonarQube"
sudo mv sonarqube-${SONAR_VERSION} /opt/sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube

# Create systemd service
echo "🛠️  Creating systemd service..."
cat <<EOF | sudo tee /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always


[Install]
WantedBy=multi-user.target
EOF

# Start SonarQube
echo "Starting SonarQube service..."
sudo systemctl daemon-reexec
sudo systemctl enable sonarqube
sudo systemctl start sonarqube || handle_error "starting SonarQube"

echo "SonarQube installation complete!"
echo "Access SonarQube at: http://localhost:9000"