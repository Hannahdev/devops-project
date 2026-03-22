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

        stage('Run Tests') {
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            mkdir -p ${REPORT_DIR}
                            . venv/bin/activate
                            pytest -v --junitxml=${REPORT_DIR}/pytest.xml
                        '''
                    } else {
                        bat '''
                            if not exist %REPORT_DIR% mkdir %REPORT_DIR%
                            call venv\\Scripts\\activate.bat
                            venv\\Scripts\\pytest -v --junitxml=%REPORT_DIR%\\pytest.xml
                        '''
                    }
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // USER and PASS are the labels Jenkins uses to map your saved credentials
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials1', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        if (isUnix()) {
                            sh '''
                                echo $PASS | docker login -u $USER --password-stdin
                                docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                                docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                                docker push ${DOCKERHUB_REPO}:latest
                            '''
                        } else {
                            bat '''
                                @echo off
                                :: Use PowerShell to safely pipe the password/token on Windows
                                powershell -Command "$env:PASS | docker login -u $env:USER --password-stdin"
                                docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                                docker tag %IMAGE_NAME%:%IMAGE_TAG% %DOCKERHUB_REPO%:latest
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
                withCredentials([file(credentialsId: 'KUBE_CONFIG', variable: 'KUBECONFIG_FILE')]) {
                    script {
                        if (isUnix()) {
                            sh '''
                                mkdir -p ~/.kube
                                cp $KUBECONFIG_FILE ~/.kube/config
                                export KUBECONFIG=~/.kube/config
                                kubectl set image deployment/inventory-app inventory-app=${DOCKERHUB_REPO}:latest
                                kubectl rollout status deployment/inventory-app
                            '''
                        } else {
                            bat '''
                                if not exist "%USERPROFILE%\\.kube" mkdir "%USERPROFILE%\\.kube"
                                copy "%KUBECONFIG_FILE%" "%USERPROFILE%\\.kube\\config"
                                set KUBECONFIG=%USERPROFILE%\\.kube\\config
                                kubectl set image deployment/inventory-app inventory-app=%DOCKERHUB_REPO%:latest
                                kubectl rollout status deployment/inventory-app
                            '''
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