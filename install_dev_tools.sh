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



sudo apt update && sudo apt upgrade -y


echo "deb https://releases.jfrog.io/artifactory/artifactory-debs xenial main" | sudo tee -a /etc/apt/sources.list.d/artifactory.list
curl -fsSL https://releases.jfrog.io/artifactory/api/gpg/key/public | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/artifactory.gpg
sudo apt update

sudo apt install jfrog-artifactory-oss -y

sudo systemctl start artifactory.service
sudo systemctl enable artifactory.service

sudo adduser nexus
sudo visudo
# Add: nexus ALL=(ALL) NOPASSWD: ALL


#curl -v https://download.sonatype.com/nexus/3/nexus-3.45.0-01-unix.tar.gz --output nexus-latest-unix.tar.gz

cd /opt
sudo apt install wget -y
sudo  wget https://cdn.download.sonatype.com/repository/downloads-prod-group/3/nexus-3.45.0-01-unix.tar.gz
sudo tar -xvzf latest-unix.tar.gz
sudo mv nexus-3.* nexus
sudo chown -R nexus:nexus /opt/nexus /opt/sonatype-work


#!/bin/bash

# Define the nexus.rc file path
NEXUS_RC_PATH="/opt/nexus/bin/nexus.rc"

# Check if the file exists
if [ -f "$NEXUS_RC_PATH" ]; then
    echo 'Configuring Nexus to run as user "nexus"...'
    echo 'run_as_user="nexus"' > "$NEXUS_RC_PATH"
    echo "Configuration updated successfully."
else
    echo "Error: $NEXUS_RC_PATH does not exist."
    exit 1
fi


# Create systemd service
echo "🛠️  Creating systemd service..."
cat <<EOF | sudo tee /etc/systemd/system/nexus.service
[Unit]
Description=Nexus service
After=syslog.target network.target

[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOF


sudo systemctl start nexus
sudo systemctl disable nexus


# Variables
ARTIFACTORY_HOME=/opt/jfrog/artifactory
ARTIFACTORY_USER=artifactory
ARTIFACTORY_GROUP=artifactory
POSTGRES_USER=artifactory
POSTGRES_DB=artifactory
POSTGRES_PASSWORD=Devops@1234
JDBC_DRIVER_URL=https://jdbc.postgresql.org/download/postgresql-42.6.0.jar
JDBC_DRIVER_NAME=postgresql-42.6.0.jar

# Create artifactory user and group
if ! id "$ARTIFACTORY_USER" &>/dev/null; then
    sudo groupadd $ARTIFACTORY_GROUP
    sudo useradd -r -s /bin/false -g $ARTIFACTORY_GROUP $ARTIFACTORY_USER
fi

# Install PostgreSQL
if ! command -v psql &>/dev/null; then
    if [ -f /etc/debian_version ]; then
        sudo apt update
        sudo apt install -y postgresql postgresql-contrib
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y postgresql-server postgresql-contrib
        sudo postgresql-setup initdb
    fi
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
fi



# Download and install Artifactory
wget -O artifactory.tar.gz https://releases.jfrog.io/artifactory/artifactory-pro/org/artifactory/pro/jfrog-artifactory-pro/7.77.5/jfrog-artifactory-pro-7.77.5-linux.tar.gz
tar -xzf artifactory.tar.gz
sudo mv jfrog-artifactory-pro-7.77.5 $ARTIFACTORY_HOME
sudo chown -R $ARTIFACTORY_USER:$ARTIFACTORY_GROUP $ARTIFACTORY_HOME

# Create PID folder
sudo mkdir -p $ARTIFACTORY_HOME/var/work/artifactory/tomcat
sudo chown -R $ARTIFACTORY_USER:$ARTIFACTORY_GROUP $ARTIFACTORY_HOME/var/work




# Configure system.yaml
cat <<EOF | sudo tee $ARTIFACTORY_HOME/var/etc/system.yaml
shared:
  database:
    type: postgresql
    driver: org.postgresql.Driver
    url: jdbc:postgresql://localhost:5432/$POSTGRES_DB
    username: $POSTGRES_USER
    password: $POSTGRES_PASSWORD
  user: $ARTIFACTORY_USER
  group: $ARTIFACTORY_GROUP
EOF


# Download JDBC driver
wget -O $JDBC_DRIVER_NAME $JDBC_DRIVER_URL
sudo mv $JDBC_DRIVER_NAME $ARTIFACTORY_HOME/app/artifactory/tomcat/lib/


# Create systemd service
cat <<EOF | sudo tee /etc/systemd/system/artifactory.service
[Unit]
Description=JFrog Artifactory
After=network.target

[Service]
Type=simple
ExecStart=$ARTIFACTORY_HOME/app/bin/artifactory.sh start
ExecStop=$ARTIFACTORY_HOME/app/bin/artifactory.sh stop
Restart=on-failure
User=$ARTIFACTORY_USER

[Install]
WantedBy=multi-user.target
EOF


# Generate master key
openssl rand -base64 32 > "$MASTER_KEY_PATH"

# Set permissions
chown artifactory:artifactory "$MASTER_KEY_PATH"
chmod 600 "$MASTER_KEY_PATH"

# Configure PostgreSQL
sudo -u postgres psql <<EOF
CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';
CREATE DATABASE $POSTGRES_DB;
GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl start artifactory
sudo systemctl enable artifactory

echo "Artifactory installation complete. Access it at http://<your-server-ip>:8081/artifactory"