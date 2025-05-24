pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key') 
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    }

    stages {
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Wait for EC2') {
            steps {
                echo 'Waiting 60 seconds for EC2 instance to be ready...'
                sleep 60
            }
        }

        stage('Ansible Setup and Execute') {
            steps {
                dir('ansible') {
                    sh '''
                    ansible-playbook -i inventory.ini playbook.yml
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}
