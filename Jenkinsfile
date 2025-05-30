pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

    stages {
        stage('Terraform Init and Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws_creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
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
                        mkdir -p ~/.ssh
                        cp ${SSH_KEY} ~/.ssh/jenk.pem
                        chmod 600 ~/.ssh/jenk.pem
                        ansible-playbook -i inventory.ini playbook.yml --private-key ~/.ssh/jenk.pem -u ec2-user
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
            dir('terraform') {
                sh 'terraform output'
            }
        }
    }
}
