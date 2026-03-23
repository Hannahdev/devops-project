pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'hasnaeelmir/inventory-app'
        VM_IP          = "20.199.176.237"
        VM_USER        = "azureuser"
        // Ensure this path is correct for your Jenkins node
        PYTHON_PATH    = "C:\\Users\\dell\\AppData\\Local\\Programs\\Python\\Python313\\python.exe"
    }

    stages {
        stage('Checkout') {
            steps {
                // Standard checkout from the repo linked to the job
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

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials1', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    // Using powershell for the login to handle the variable safely
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
                // Uses your 'id_rsa_fixed' uploaded as a Secret File
                withCredentials([file(credentialsId: 'azure-ssh-key-file', variable: 'KEY_PATH')]) {
                    powershell """
                        Write-Host "--- Securing Private Key Permissions ---"
                        \$keyPath = "${env.KEY_PATH}"
                        
                        # 1. Strip all inherited Windows permissions (Users, Everyone, etc.)
                        \$acl = Get-Acl \$keyPath
                        \$acl.SetAccessRuleProtection(\$true, \$false)
                        
                        # 2. Grant ONLY the current Jenkins service account 'Read' access
                        \$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
                        \$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(\$user, 'Read', 'Allow')
                        \$acl.AddAccessRule(\$rule)
                        
                        # 3. Apply the ACL so OpenSSH accepts it as a private key
                        Set-Acl \$keyPath \$acl
                        
                        Write-Host "--- Connecting to Master VM: ${env.VM_IP} ---"
                        # Execute the deployment command on the remote VM
                        & C:\\Windows\\System32\\OpenSSH\\ssh.exe -i \$keyPath -o StrictHostKeyChecking=no ${env.VM_USER}@${env.VM_IP} "kubectl set image deployment/inventory-app inventory-app=${env.DOCKERHUB_REPO}:latest && kubectl rollout status deployment/inventory-app"
                        
                        if (\$LASTEXITCODE -ne 0) { 
                            Write-Error "Deployment failed on the remote VM."
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
            // Clean up the workspace to ensure the next build starts fresh
            cleanWs()
        }
    }
}