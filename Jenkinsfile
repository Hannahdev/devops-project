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

        // -----------------------------
        // 1. Checkout
        // -----------------------------
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Hannahdev/devops-project.git'
            }
        }

        // -----------------------------
        // 2. Install Dependencies
        // -----------------------------
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

        // -----------------------------
        // 3. Run Tests
        // -----------------------------
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

        // -----------------------------
        // 4. Build Docker Image
        // -----------------------------
        stage('Build Docker Image') {
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                            docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                        '''
                    } else {
                        bat '''
                            docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                            docker tag %IMAGE_NAME%:%IMAGE_TAG% %DOCKERHUB_REPO%:latest
                        '''
                    }
                }
            }
        }

        // -----------------------------
        // 5. Push to Docker Hub
        // -----------------------------
        stage('Push to DockerHub') {
            steps {
                script {
                    if (isUnix()) {
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials1', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                            sh '''
                                docker login -u $USER -p $PASS
                                docker push ${DOCKERHUB_REPO}:latest
                            '''
                        }
                    } else {
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials1', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                            bat '''
                                docker login -u %USER% -p %PASS%
                                docker push %DOCKERHUB_REPO%:latest
                            '''
                        }
                    }
                }
            }
        }

        // -----------------------------
        // 6. Deploy to Kubernetes (Azure VM)
        // -----------------------------
        stage('Deploy to Kubernetes') {
            when {
                expression { params.DEPLOY }
            }
            steps {
                withCredentials([file(credentialsId: 'KUBE_CONFIG', variable: 'KUBECONFIG_FILE')]) {
                    script {
                        if (isUnix()) {
                            sh '''
                                mkdir -p ~/.kube
                                cp $KUBECONFIG_FILE ~/.kube/config
                                export KUBECONFIG=~/.kube/config

                                kubectl set image deployment/inventory-app inventory-app=${DOCKERHUB_REPO}:latest --record
                                kubectl rollout status deployment/inventory-app

                                kubectl get pods
                                kubectl get svc
                            '''
                        } else {
                            bat '''
                                mkdir %USERPROFILE%\\.kube
                                copy %KUBECONFIG_FILE% %USERPROFILE%\\.kube\\config
                                set KUBECONFIG=%USERPROFILE%\\.kube\\config

                                kubectl set image deployment/inventory-app inventory-app=%DOCKERHUB_REPO%:latest --record
                                kubectl rollout status deployment/inventory-app

                                kubectl get pods
                                kubectl get svc
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