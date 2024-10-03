# PowerShell script to bootstrap a Windows VM

# Install Chocolatey package manager
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install some common tools
choco install -y git vscode

# Set up environment variables or other configuration
[Environment]::SetEnvironmentVariable("MY_VAR", "value", "Machine")

Write-Output "Bootstrap script completed."
