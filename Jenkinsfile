pipeline {
    agent { 
        label 'dev' 
    }
    
    environment {
        AWS_DEFAULT_REGION = 'us-west-2'
        TF_IN_AUTOMATION   = 'true'
        // Add AWS credentials if not using IAM Roles on Jenkins worker
        // AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        // AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Git Checkout') {
            steps {
                echo 'Cloning GitHub repository...'
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/rakkasimahe27-crypto/terraform-1.git'
                    ]]
                ])
            }
        }

        stage('Check Environment') {
            steps {
                sh '''
                    echo "Checking system tools:"
                    terraform version
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir('day-6-modules') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('day-6-modules') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Manual Approval') {
            steps {
                input message: 'Review plan output above. Apply changes?', ok: 'Approve & Apply'
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('day-6-modules') {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }
    }

    post {
        success {
            echo '========================================='
            echo 'Terraform deployment completed SUCCESSFULLY'
            echo '========================================='
        }
        failure {
            echo '========================================='
            echo 'Terraform deployment FAILED'
            echo 'Check the Jenkins console output.'
            echo '========================================='
        }
        always {
            cleanWs() // Clean up workspace after build completes
        }
    }
}
