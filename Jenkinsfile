pipeline {
    agent any
   
    environment {
        GIT_CREDENTIALS = credentials('github-pat') 
        MYSQL_DB_HOST = 'jdbc:mysql://localhost'
        MYSQL_DB_PORT = '3306'
        MYSQL_DB = 'Teacher'
        MYSQL_USERNAME = credentials('MYSQL_USERNAME') // Securely inject username
        MYSQL_PASSWORD = credentials('MYSQL_PASSWORD') // Securely inject password

        SONARQUBE_SERVER = 'SonarQubeServer' // SonarQube server name in Jenkins
        SONAR_PROJECT_KEY = 'Ecommerce' // Unique project key for SonarQube
    }


    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/bishtchetan11/Ecommerce.git',
                    branch: 'main',
                    credentialsId: 'github-pat'
            }
        }



        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=${SONAR_PROJECT_KEY}'
                }
            }
        }


        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

      /***  stage('Test') {
            steps {
                sh 'mvn test'
            }
        } ***/

        stage('Package') {
            steps {
                sh 'mvn package -DMYSQL_DB_HOST=$MYSQL_DB_HOST -DMYSQL_DB_PORT=$MYSQL_DB_PORT -DMYSQL_DB=$MYSQL_DB -DMYSQL_USER=$MYSQL_USERNAME -DMYSQL_PASSWORD=$MYSQL_PASSWORD'
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: '**/target/ecommerce-${env.BUILD_NUMBER}.jar', fingerprint: true
            }
        }


            stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }





    post {
        success {
            echo 'Build completed successfully!'
        }
        failure {
            echo 'Build failed.'
        }
    }
}
