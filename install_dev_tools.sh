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
                                                                                                                                                                                                                                                                                                                                    33,110        All