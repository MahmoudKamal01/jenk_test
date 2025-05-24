pipeline {
    agent any

    environment {
        // Example: define environment variables if needed
        NODE_ENV = 'production'
    }

    stages {
        stage('Clone Repo') {
            steps {
                echo 'Cloning repository...'
                // Code checkout is usually handled automatically if using Multibranch Pipeline
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'npm install' // Change this based on your project type
            }
        }

        stage('Run Tests') {
            steps {
                echo 'npm test' // or use your test framework
            }
        }

        stage('Build') {
            steps {
                echo 'npm run build' // or your specific build command
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying...'
                // Your deployment logic (rsync, ssh, ftp, docker, etc.)
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
