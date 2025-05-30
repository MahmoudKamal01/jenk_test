pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Terraform Init and Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws_creds'
                ]]) {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
                    }
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
                withCredentials([file(credentialsId: 'jenkins-ssh-key', variable: 'SSH_KEY')]) {
                    dir('ansible') {
                        sh """
                        chmod 600 ${SSH_KEY}
                        ansible-playbook -i inventory.ini playbook.yml --private-key ${SSH_KEY}
                        """
                    }
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
