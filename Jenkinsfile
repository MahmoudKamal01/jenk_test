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
                sh 'ls -la scripts/'  // Verify script exists
            }
        }

        stage('Verify EC2 Connectivity') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'jenkins-ssh-key',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    sh """
                    # Test basic SSH connection first
                    echo "Testing SSH connection to ${EC2_IP}"
                    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} 'echo "SSH connection successful!"'
                    """
                }
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
                    # Copy script with verbose output
                    echo "Transferring deploy.sh to ${EC2_IP}:/tmp/"
                    scp -v -o StrictHostKeyChecking=no -i ${SSH_KEY} ./scripts/deploy.sh ${SSH_USER}@${EC2_IP}:/tmp/
                    
                    # Verify transfer
                    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} \
                        'ls -la /tmp/deploy.sh && file /tmp/deploy.sh'
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
                    # Execute with detailed logging
                    echo "Executing script on ${EC2_IP}"
                    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} \
                        'chmod +x /tmp/deploy.sh && /tmp/deploy.sh > /tmp/deploy.log 2>&1'
                    
                    # Get execution logs
                    echo "Script output:"
                    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} 'cat /tmp/deploy.log'
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed"
            cleanWs()  // Clean workspace when done
        }
        success {
            echo "Success! Script executed on ${EC2_IP}"
            // Add success notification here
        }
        failure {
            echo "Pipeline failed! Check these areas:"
            echo "1. SSH key permissions (chmod 600)"
            echo "2. EC2 security group rules"
            echo "3. Terraform output values"
            // Add failure notification here
        }
    }
}
