pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'hasnaeelmir/inventory-app'
        VM_IP          = "20.199.176.237"
        VM_USER        = "azureuser"
        PYTHON_PATH    = "C:\\Users\\dell\\AppData\\Local\\Programs\\Python\\Python313\\python.exe"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
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

        stage('Unit Tests') {
            steps {
                bat """
                    call venv\\Scripts\\activate.bat
                    pytest test_app.py
                """
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials1', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    powershell """
                        \$env:PASS | docker login -u \$env:USER --password-stdin
                        docker build -t ${env.DOCKERHUB_REPO}:latest .
                        docker push ${env.DOCKERHUB_REPO}:latest
                    """
                }
            }
        }

        stage('Deploy to Azure') {
            steps {
                withCredentials([file(credentialsId: 'azure-ssh-key-file', variable: 'KEY_PATH')]) {
                    powershell """
                        Write-Host "--- Securing Private Key Permissions ---"
                        \$keyPath = "${env.KEY_PATH}"
                        
                        \$acl = Get-Acl \$keyPath
                        \$acl.SetAccessRuleProtection(\$true, \$false)
                        
                        \$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
                        \$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(\$user, 'Read', 'Allow')
                        \$acl.AddAccessRule(\$rule)
                        Set-Acl \$keyPath \$acl
                        
                        Write-Host "--- Connecting to Master VM and Applying Changes ---"
                        
                        # Ici, on cree une variable locale propre a PowerShell avec la valeur de Jenkins
                        \$imageRepo = "${env.DOCKERHUB_REPO}"
                        
                        # On injecte directement la variable dans la ligne de commande SSH
                        & C:\\Windows\\System32\\OpenSSH\\ssh.exe -i \$keyPath -o StrictHostKeyChecking=no -o ServerAliveInterval=30 ${env.VM_USER}@${env.VM_IP} "
                            kubectl apply -f service.yaml && \
                            kubectl set image deployment/inventory-app inventory-app=\$imageRepo:latest && \
                            kubectl rollout status deployment/inventory-app
                        "
                        
                        if (\$LASTEXITCODE -ne 0) { 
                            Write-Error "Deployment or Service application failed."
                            exit 1
                        }
                        Write-Host "--- Deployment Successful ---"
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