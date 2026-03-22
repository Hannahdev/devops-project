pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'hasnaeelmir/inventory-app'
        VM_IP = "20.199.176.237"
        VM_USER = "azureuser"
        PYTHON_PATH = "C:\\Users\\dell\\AppData\\Local\\Programs\\Python\\Python313\\python.exe"
    }

    stages {
        stage('Checkout') {
            steps {
                // FIXED: Using shallow clone to prevent RPC/Timeout errors
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    extensions: [[$class: 'CloneOption', depth: 1, noTags: false, shallow: true]], 
                    userRemoteConfigs: [[url: 'https://github.com/Hannahdev/devops-project.git']]
                ])
            }
        }

        stage('Install & Build') {
            steps {
                bat """
                    "%PYTHON_PATH%" -m venv venv
                    call venv\\Scripts\\activate.bat
                    pip install -r requirements.txt
                """
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials1', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    bat """
                        powershell -Command "\$env:PASS | docker login -u \$env:USER --password-stdin"
                        docker build -t %DOCKERHUB_REPO%:latest .
                        docker push %DOCKERHUB_REPO%:latest
                    """
                }
            }
        }

        stage('Deploy to Azure') {
            steps {
                // Requires the 'SSH Agent' plugin to be installed in Jenkins
                sshagent(['azure-ssh-key']) {
                    bat """
                        ssh -o StrictHostKeyChecking=no %VM_USER%@%VM_IP% "kubectl set image deployment/inventory-app inventory-app=%DOCKERHUB_REPO%:latest && kubectl rollout status deployment/inventory-app"
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}