# Environment Preparation
# ------------------------
# Install HyperV
Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All

# Enable WinRM
Enable-PSRemoting -SkipNetworkProfileCheck -Force
Set-WSManInstance WinRM/Config/WinRS -ValueSet @{MaxMemoryPerShellMB = 1024}
Set-WSManInstance WinRM/Config -ValueSet @{MaxTimeoutms=1800000}
Set-WSManInstance WinRM/Config/Client -ValueSet @{TrustedHosts="*"}
Set-WSManInstance WinRM/Config/Service/Auth -ValueSet @{Negotiate = $true}

# Configure HTTPS for WinRM
# --------------------------
# Create CA Certificate
$rootCaName = "DevRootCA"
$rootCaPassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force 
$rootCaCertificate = Get-ChildItem cert:\LocalMachine\Root | Where-Object {$_.subject -eq "CN=$rootCaName"}
if (!$rootCaCertificate) {
    Get-ChildItem cert:\LocalMachine\My | Where-Object {$_.subject -eq "CN=$rootCaName"} | Remove-Item -Force
    if (Test-Path ".\$rootCaName.cer") {
        Remove-Item ".\$rootCaName.cer" -Force
    }
    if (Test-Path ".\$rootCaName.pfx") {
        Remove-Item ".\$rootCaName.pfx" -Force
    }
    $params = @{
        Type = 'Custom'
        DnsName = $rootCaName
        Subject = "CN=$rootCaName"
        KeyExportPolicy = 'Exportable'
        CertStoreLocation = 'Cert:\LocalMachine\My'
        KeyUsageProperty = 'All'
        KeyUsage = 'None'
        Provider = 'Microsoft Strong Cryptographic Provider'
        KeySpec = 'KeyExchange'
        KeyLength = 4096
        HashAlgorithm = 'SHA256'
        KeyAlgorithm = 'RSA'
        NotAfter = (Get-Date).AddYears(5)
    }
    $rootCaCertificate = New-SelfSignedCertificate @params

    Export-Certificate -Cert $rootCaCertificate -FilePath ".\$rootCaName.cer" -Verbose
    Export-PfxCertificate -Cert $rootCaCertificate -FilePath ".\$rootCaName.pfx" -Password $rootCaPassword -Verbose
    Get-ChildItem cert:\LocalMachine\My | Where-Object {$_.subject -eq "CN=$rootCaName"} | Remove-Item -Force
    Import-PfxCertificate -FilePath ".\$rootCaName.pfx" -CertStoreLocation Cert:\LocalMachine\Root -Password $rootCaPassword -Exportable -Verbose
    Import-PfxCertificate -FilePath ".\$rootCaName.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $rootCaPassword -Exportable -Verbose
    $rootCaCertificate = Get-ChildItem cert:\LocalMachine\My | Where-Object {$_.subject -eq "CN=$rootCaName"}
}

# Create Host Certificate
$hostName = [System.Net.Dns]::GetHostName()
$hostPassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$hostCertificate = Get-ChildItem cert:\LocalMachine\My | Where-Object {$_.subject -eq "CN=$hostName"}
if (!$hostCertificate) {
    if (Test-Path ".\$hostName.cer") {
        Remove-Item ".\$hostName.cer" -Force
    }
    if (Test-Path ".\$hostName.pfx") {
        Remove-Item ".\$hostName.pfx" -Force
    }
    $dnsNames = @($hostName, "localhost", "127.0.0.1") + [System.Net.Dns]::GetHostByName($env:computerName).AddressList.IPAddressToString
    
    $params = @{
        Type = 'Custom'
        DnsName = $dnsNames
        Subject = "CN=$hostName"
        KeyExportPolicy = 'Exportable'
        CertStoreLocation = 'Cert:\LocalMachine\My'
        KeyUsageProperty = 'All'
        KeyUsage = @('KeyEncipherment','DigitalSignature','NonRepudiation')
        TextExtension = @("2.5.29.37={text}1.3.6.1.5.5.7.3.1,1.3.6.1.5.5.7.3.2")
        Signer = $rootCaCertificate
        Provider = 'Microsoft Strong Cryptographic Provider'
        KeySpec = 'KeyExchange'
        KeyLength = 2048
        HashAlgorithm = 'SHA256'
        KeyAlgorithm = 'RSA'
        NotAfter = (Get-Date).AddYears(2)
    }
    $hostCertificate = New-SelfSignedCertificate @params
    Export-Certificate -Cert $hostCertificate -FilePath ".\$hostName.cer" -Verbose
    Export-PfxCertificate -Cert $hostCertificate -FilePath ".\$hostName.pfx" -Password $hostPassword -Verbose
    Get-ChildItem cert:\LocalMachine\My | Where-Object {$_.subject -eq "CN=$hostName"} | Remove-Item -Force
    Import-PfxCertificate -FilePath ".\$hostName.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $hostPassword -Exportable -Verbose
    $hostCertificate = Get-ChildItem cert:\LocalMachine\My | Where-Object {$_.subject -eq "CN=$hostName"}
}

# Configure WinRM for HTTPS
Get-ChildItem wsman:\localhost\Listener\ | Where-Object -Property Keys -eq 'Transport=HTTPS' | Remove-Item -Recurse
New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $($hostCertificate.Thumbprint) -Force -Verbose
Restart-Service WinRM -Verbose

# Allow HTTPS through Firewall
New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "WinRMHTTPSIn" -Profile Any -LocalPort 5986 -Protocol TCP -Verbose

# Configure HTTP for WinRM (optional)
# -----------------------------------
# Get the public networks
$PubNets = Get-NetConnectionProfile -NetworkCategory Public -ErrorAction SilentlyContinue 

# Set the profile to private
foreach ($PubNet in $PubNets) {
    Set-NetConnectionProfile -InterfaceIndex $PubNet.InterfaceIndex -NetworkCategory Private
}

# Configure winrm
Set-WSManInstance WinRM/Config/Service -ValueSet @{AllowUnencrypted = $true}

# Restore network categories
foreach ($PubNet in $PubNets) {
    Set-NetConnectionProfile -InterfaceIndex $PubNet.InterfaceIndex -NetworkCategory Public
}

# Remove and create HTTP listener
Get-ChildItem wsman:\localhost\Listener\ | Where-Object -Property Keys -eq 'Transport=HTTP' | Remove-Item -Recurse
New-Item -Path WSMan:\localhost\Listener -Transport HTTP -Address * -Force -Verbose
Restart-Service WinRM -Verbose

# Allow HTTP through Firewall
New-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)" -Name "WinRMHTTPIn" -Profile Any -LocalPort 5985 -Protocol TCP -Verbose

# Build and Install the Provider
# -------------------------------
# Set up Go environment
$env:GOPATH = "C:\GoWorkspace"
[System.Environment]::SetEnvironmentVariable('GOPATH', $env:GOPATH, 'User')

# Clone and Build the Provider
mkdir -p $env:GOPATH\src\github.com\taliesins
Set-Location $env:GOPATH\src\github.com\taliesins
git clone https://github.com/taliesins/terraform-provider-hyperv.git
Set-Location terraform-provider-hyperv
make build

# Move the Provider Binary
$providerBinary = "$env:GOPATH\bin\terraform-provider-hyperv"
# Move or copy the binary to a suitable location, e.g., a Terraform plugins directory

# Test the Provider
make test

# Optional Debugging Setup
# -------------------------
# Enable Terraform Debugging
Set-Variable TF_LOG=TRACE
# Enable WinRM Debugging
Set-Variable WINRMCP_DEBUG=TRUE
