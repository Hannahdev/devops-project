pipeline {
    agent any

    parameters {
        booleanParam(name: 'DEPLOY', defaultValue: true, description: 'Deploy to Kubernetes')
    }

    environment {
        IMAGE_NAME = 'inventory-app'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKERHUB_REPO = 'hasnaeelmir/inventory-app'
        REPORT_DIR = 'reports'
        PYTHON_PATH = "C:\\Users\\dell\\AppData\\Local\\Programs\\Python\\Python313\\python.exe"
        VM_IP = "20.199.176.237"  // Adresse de ta VM/master Kubernetes
        VM_USER = "azureuser"      // Utilisateur pour SSH
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Hannahdev/devops-project.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            python3 -m venv venv
                            . venv/bin/activate
                            pip install --upgrade pip
                            pip install -r requirements.txt
                        '''
                    } else {
                        bat '''
                            "%PYTHON_PATH%" -m venv venv
                            call venv\\Scripts\\activate.bat
                            venv\\Scripts\\python -m pip install --upgrade pip
                            venv\\Scripts\\pip install -r requirements.txt
                        '''
                    }
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials1', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        if (isUnix()) {
                            sh '''
                                echo "venv/\n.git/\n__pycache__/\nreports/" > .dockerignore
                                echo $PASS | docker login -u $USER --password-stdin
                                docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                                docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                                docker push ${DOCKERHUB_REPO}:latest
                            '''
                        } else {
                            bat '''
                                @echo off
                                echo venv/ > .dockerignore
                                echo .git/ >> .dockerignore
                                echo __pycache__/ >> .dockerignore
                                echo reports/ >> .dockerignore

                                powershell -Command "$env:PASS | docker login -u $env:USER --password-stdin"
                                if errorlevel 1 exit /b 1

                                docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                                docker tag %IMAGE_NAME%:%IMAGE_TAG% %DOCKERHUB_REPO%:latest
                                docker tag %IMAGE_NAME%:%IMAGE_TAG% %DOCKERHUB_REPO%:%IMAGE_TAG%
                                docker push %DOCKERHUB_REPO%:%IMAGE_TAG%
                                docker push %DOCKERHUB_REPO%:latest
                            '''
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when { expression { params.DEPLOY } }
            steps {
                // Utilisation de SSH pour accéder à la VM et copier kubeconfig
                withCredentials([sshUserPrivateKey(credentialsId: 'azure-ssh-key', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    script {
                        if (isUnix()) {
                            sh """
                                ssh -o StrictHostKeyChecking=no -i $SSH_KEY $VM_USER@$VM_IP "mkdir -p ~/.kube"
                                scp -i $SSH_KEY KubeConfig.yaml $VM_USER@$VM_IP:~/.kube/config
                                ssh -i $SSH_KEY $VM_USER@$VM_IP "kubectl set image deployment/inventory-app inventory-app=${DOCKERHUB_REPO}:latest"
                                ssh -i $SSH_KEY $VM_USER@$VM_IP "kubectl rollout status deployment/inventory-app"
                            """
                        } else {
                            bat """
                                :: Windows PowerShell pour SSH
                                powershell -Command "ssh -o StrictHostKeyChecking=no -i %SSH_KEY% %VM_USER%@%VM_IP% 'mkdir -p ~/.kube'"
                                powershell -Command "scp -i %SSH_KEY% KubeConfig.yaml %VM_USER%@%VM_IP%:~/.kube/config"
                                powershell -Command "ssh -i %SSH_KEY% %VM_USER%@%VM_IP% 'kubectl set image deployment/inventory-app inventory-app=%DOCKERHUB_REPO%:latest'"
                                powershell -Command "ssh -i %SSH_KEY% %VM_USER%@%VM_IP% 'kubectl rollout status deployment/inventory-app'"
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            junit testResults: 'reports/pytest.xml', allowEmptyResults: true
            archiveArtifacts artifacts: 'reports/*.xml', allowEmptyArchive: true
            cleanWs()
        }
    }
}