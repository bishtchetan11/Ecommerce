pipeline {
    agent any
   
    environment {
        GIT_CREDENTIALS = credentials('github-pat') // ID from Jenkins credentials
    }


    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-username/sample-java-project.git',
                credentialsId: 'github-pat'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
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
