pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        TF_DIR = 'terraform'
        ANSIBLE_DIR = 'ansible'
    }

    stages {
        stage('Check Terraform Files') {
            steps {
                dir(env.TF_DIR) {
                    script {
                        def tfFiles = findFiles(glob: '*.tf')
                        if (tfFiles.size() == 0) {
                            error("No Terraform files found in ${env.TF_DIR} directory")
                        }
                    }
                }
            }
        }

        stage('Terraform Init and Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-access-key',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    dir(env.TF_DIR) {
                        sh 'terraform init -input=false'
                        sh 'terraform validate'
                        sh 'terraform plan -out=tfplan'
                        sh 'terraform apply -input=false -auto-approve tfplan'
                    }
                }
            }
        }

        stage('Generate Inventory') {
            steps {
                script {
                    // Ensure inventory generation script exists and is executable
                    def inventoryScript = fileExists('generate_inventory.sh') 
                    if (inventoryScript) {
                        sh 'chmod +x generate_inventory.sh && ./generate_inventory.sh'
                    } else {
                        echo 'No inventory generation script found, using static inventory'
                    }
                }
            }
        }

        stage('Wait for EC2') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitUntil {
                        script {
                            // Add actual EC2 health check here
                            echo "Waiting for EC2 to be ready..."
                            sleep 30
                            return true // Replace with actual check
                        }
                    }
                }
            }
        }

        stage('Ansible Execution') {
            steps {
                dir(env.ANSIBLE_DIR) {
                    sh 'ansible-galaxy install -r requirements.yml' // If needed
                    sh 'ansible-playbook -i inventory.ini playbook.yml --verbose'
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed'
            dir(env.TF_DIR) {
                script {
                    // Only destroy if you want this behavior
                    // sh 'terraform destroy -auto-approve'
                }
            }
        }
        failure {
            slackSend channel: '#jenkins',
                     message: "Pipeline ${env.JOB_NAME} #${env.BUILD_NUMBER} failed"
        }
    }
}
