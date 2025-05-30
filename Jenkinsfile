pipeline {
    agent any

    environment {
        // Get EC2 IP from Terraform output
        EC2_IP = sh(script: 'cd terraform && terraform output -raw public_ip', returnStdout: true).trim()
        SSH_USER = 'ec2-user'
    }

    stages {
        stage('Checkout & Prepare') {
            steps {
                checkout scm 
            }
        }

        stage('Transfer Script') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'jenkins-ssh-key',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    sh """
                    # Copy script to EC2
                    scp -o StrictHostKeyChecking=no -i ${SSH_KEY} ./scripts/deploy.sh ${SSH_USER}@${EC2_IP}:/tmp/
                    """
                }
            }
        }

        stage('Execute Script') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'jenkins-ssh-key',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    sh """
                    # Make script executable and run it
                    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} \
                        'chmod +x /tmp/deploy.sh && /tmp/deploy.sh'
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Script execution completed. Check EC2 logs if needed."
        }
        failure {
            // Add failure notifications (Slack/Email)
            echo "Pipeline failed!"
        }
    }
}
