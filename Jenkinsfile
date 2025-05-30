pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1' // or your desired region
    }

    stages {
        stage('Terraform Init and Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-access-key'
                ]]) {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                sh './generate_inventory.sh'
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
                    sh 'ansible-playbook -i inventory.ini playbook.yml'
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
