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
                script {
                    // Verify script exists and is executable
                    if (!fileExists('scripts/deploy.sh')) {
                        error("deploy.sh not found in scripts directory")
                    }
                    sh 'chmod +x scripts/deploy.sh && ls -la scripts/'
                }
            }
        }

        stage('Debug SSH Setup') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'jenkins-ssh-key',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    script {
                        // Windows-compatible permission check
                        if (isUnix()) {
                            sh "chmod 600 ${SSH_KEY}"
                        } else {
                            bat """
                            icacls ${SSH_KEY} /reset
                            icacls ${SSH_KEY} /grant:r "%USERNAME%":F
                            icacls ${SSH_KEY} /inheritance:r
                            """
                        }
                        
                        // Enhanced connection test with timeout
                        timeout(time: 1, unit: 'MINUTES') {
                            sh """
                            echo "--- SSH DEBUG INFORMATION ---"
                            echo "Key path: ${SSH_KEY}"
                            ls -la ${SSH_KEY}
                            echo "First 3 lines of key:"
                            head -n 3 ${SSH_KEY}
                            echo "Testing connection to ${EC2_IP}"
                            ssh -vvv -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} 'echo "Connection successful"'
                            """
                        }
                    }
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
                    retry(3) {
                        timeout(time: 2, unit: 'MINUTES') {
                            sh """
                            echo "Transferring script..."
                            scp -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i ${SSH_KEY} ./scripts/deploy.sh ${SSH_USER}@${EC2_IP}:/tmp/
                            
                            echo "Verifying transfer..."
                            ssh -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} \
                                'test -f /tmp/deploy.sh && echo "File exists" || echo "File missing"'
                            """
                        }
                    }
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
                    script {
                        try {
                            def output = sh(script: """
                            ssh -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} \
                                'chmod +x /tmp/deploy.sh && /tmp/deploy.sh > /tmp/deploy.log 2>&1; cat /tmp/deploy.log'
                            """, returnStdout: true).trim()
                            
                            echo "Script Output:\n${output}"
                            
                            // Fail pipeline if script returns non-zero
                            if (output.contains("ERROR") || output.contains("failed")) {
                                error("Script execution reported errors")
                            }
                        } catch (e) {
                            // Get full logs if execution fails
                            sh """
                            ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} 'cat /tmp/deploy.log' || true
                            """
                            throw e
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed - cleaning up"
            cleanWs()
        }
        success {
            slackSend(color: 'good', message: "SUCCESS: Script deployed to ${EC2_IP}")
        }
        failure {
            slackSend(color: 'danger', message: "FAILED: Pipeline ${env.JOB_NAME} #${env.BUILD_NUMBER}")
            archiveArtifacts artifacts: '**/deploy.log', allowEmptyArchive: true
        }
        unstable {
            slackSend(color: 'warning', message: "UNSTABLE: Pipeline ${env.JOB_NAME} #${env.BUILD_NUMBER}")
        }
    }
}
