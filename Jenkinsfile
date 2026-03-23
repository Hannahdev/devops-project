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
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    extensions: [
                        [$class: 'CloneOption', depth: 1, noTags: false, shallow: true, timeout: 30],
                        [$class: 'CheckoutOption', timeout: 30]
                    ], 
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
        withCredentials([file(credentialsId: 'azure-ssh-key-file', variable: 'KEY_PATH')]) {
            bat """
                @echo off
                echo --- Fixing Key Permissions via PowerShell ---
                
                powershell -Command " ^
                    \$path = '%KEY_PATH%'; ^
                    \$acl = Get-Acl \$path; ^
                    \$acl.SetAccessRuleProtection(\$true, \$false); ^
                    \$rule = New-Object System.Security.AccessControl.FileSystemAccessRule([System.Security.Principal.WindowsIdentity]::GetCurrent().Name, 'Read', 'Allow'); ^
                    \$acl.AddAccessRule(\$rule); ^
                    Set-Acl \$path \$acl"

                echo --- Connecting to Master VM ---
                "C:\\Windows\\System32\\OpenSSH\\ssh.exe" -i "%KEY_PATH%" -o StrictHostKeyChecking=no %VM_USER%@%VM_IP% ^
                "kubectl set image deployment/inventory-app inventory-app=%DOCKERHUB_REPO%:latest && ^
                 kubectl rollout status deployment/inventory-app"
                
                if %ERRORLEVEL% NEQ 0 (
                    echo ERROR: Deployment failed.
                    exit /b %ERRORLEVEL%
                )
                echo --- Deployment Successful ---
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