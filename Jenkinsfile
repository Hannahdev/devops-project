pipeline {
    agent any

    parameters {
        booleanParam(name: 'DEPLOY', defaultValue: false, description: 'Deploy container after successful build (main branch only).')
        string(name: 'APP_PORT', defaultValue: '5000', description: 'Host port for deployed container.')
    }

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        IMAGE_NAME = 'inventory-app'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = 'inventory-app-container'
        REPORT_DIR = 'reports'
        PYTHON_PATH = "C:\\Users\\dell\\AppData\\Local\\Programs\\Python\\Python313\\python.exe"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            python3 -m venv venv
                            . venv/bin/activate
                            python -m pip install --upgrade pip
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

        stage('Build Docker Image') {
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                            docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                        '''
                    } else {
                        bat '''
                            docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                            docker tag %IMAGE_NAME%:%IMAGE_TAG% %IMAGE_NAME%:latest
                        '''
                    }
                }
            }
        }

        stage('Deploy') {
            when {
                allOf {
                    branch 'main'
                    expression { params.DEPLOY }
                }
            }
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            docker stop ${CONTAINER_NAME} >/dev/null 2>&1 || true
                            docker rm ${CONTAINER_NAME} >/dev/null 2>&1 || true
                            docker run -d --name ${CONTAINER_NAME} -p ${APP_PORT}:5000 ${IMAGE_NAME}:latest
                        '''
                    } else {
                        bat '''
                            docker stop %CONTAINER_NAME% >nul 2>nul
                            docker rm %CONTAINER_NAME% >nul 2>nul
                            docker run -d --name %CONTAINER_NAME% -p %APP_PORT%:5000 %IMAGE_NAME%:latest
                        '''
                    }
                    echo "Deployment complete. App is available on port ${params.APP_PORT}."
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