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
                        if (\$LASTEXITCODE -ne 0) { Write-Error "Docker login failed"; exit 1 }

                        docker build -t ${env.DOCKERHUB_REPO}:latest .
                        if (\$LASTEXITCODE -ne 0) { Write-Error "Docker build failed"; exit 1 }

                        docker push ${env.DOCKERHUB_REPO}:latest
                        if (\$LASTEXITCODE -ne 0) { Write-Error "Docker push failed"; exit 1 }
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

                        \$target  = "${env.VM_USER}@${env.VM_IP}"
                        \$sshOpts = @("-i", \$keyPath, "-o", "StrictHostKeyChecking=no", "-o", "ServerAliveInterval=30")

                        # ── Verify YAML files exist in workspace ──────────────────────────
                        Write-Host "--- Verifying manifest files in workspace ---"
                        \$serviceYaml    = "${env.WORKSPACE}\\service.yaml"
                        \$deploymentYaml = "${env.WORKSPACE}\\deployment.yaml"

                        if (-not (Test-Path \$serviceYaml)) {
                            Write-Error "service.yaml not found at \$serviceYaml"
                            exit 1
                        }
                        if (-not (Test-Path \$deploymentYaml)) {
                            Write-Error "deployment.yaml not found at \$deploymentYaml"
                            exit 1
                        }
                        Write-Host "Both manifest files found."

                        # ── Copy YAML files to VM ─────────────────────────────────────────
                        Write-Host "--- Copying manifests to VM ---"

                        & C:\\Windows\\System32\\OpenSSH\\scp.exe @sshOpts \$serviceYaml "\${target}:~/service.yaml"
                        if (\$LASTEXITCODE -ne 0) { Write-Error "scp service.yaml failed"; exit 1 }

                        & C:\\Windows\\System32\\OpenSSH\\scp.exe @sshOpts \$deploymentYaml "\${target}:~/deployment.yaml"
                        if (\$LASTEXITCODE -ne 0) { Write-Error "scp deployment.yaml failed"; exit 1 }

                        # ── Verify files landed on VM ─────────────────────────────────────
                        Write-Host "--- Verifying files on VM ---"
                        & C:\\Windows\\System32\\OpenSSH\\ssh.exe @sshOpts \$target "ls -la ~/service.yaml ~/deployment.yaml"
                        if (\$LASTEXITCODE -ne 0) { Write-Error "Manifest files not found on VM after scp"; exit 1 }

                        # ── Apply Service ─────────────────────────────────────────────────
                        Write-Host "--- Applying Service ---"
                        & C:\\Windows\\System32\\OpenSSH\\ssh.exe @sshOpts \$target "kubectl apply -f ~/service.yaml"
                        if (\$LASTEXITCODE -ne 0) { Write-Error "kubectl apply service.yaml failed"; exit 1 }

                        # ── Apply Deployment ──────────────────────────────────────────────
                        Write-Host "--- Applying Deployment ---"
                        & C:\\Windows\\System32\\OpenSSH\\ssh.exe @sshOpts \$target "kubectl apply -f ~/deployment.yaml"
                        if (\$LASTEXITCODE -ne 0) { Write-Error "kubectl apply deployment.yaml failed"; exit 1 }

                        # ── Restart to force latest image pull ────────────────────────────
                        Write-Host "--- Restarting Deployment ---"
                        & C:\\Windows\\System32\\OpenSSH\\ssh.exe @sshOpts \$target "kubectl rollout restart deployment/inventory-app"
                        if (\$LASTEXITCODE -ne 0) { Write-Error "kubectl rollout restart failed"; exit 1 }

                        # ── Wait for rollout ──────────────────────────────────────────────
                        Write-Host "--- Waiting for Rollout ---"
                        & C:\\Windows\\System32\\OpenSSH\\ssh.exe @sshOpts \$target "kubectl rollout status deployment/inventory-app --timeout=120s"
                        if (\$LASTEXITCODE -ne 0) { Write-Error "Rollout failed or timed out"; exit 1 }

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