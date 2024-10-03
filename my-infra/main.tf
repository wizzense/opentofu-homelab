terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "1.2.1"
    }
  }
}

provider "hyperv" {
  user            = "admin"
  password        = ""
  host            = "192.168.87.82"
  port            = 5986
  https           = true
  insecure        = true # This skips SSL validation
  use_ntlm        = true # Use NTLM as it's enabled on the WinRM service
  tls_server_name = ""
  cacert_path     = "" # Leave empty if skipping SSL validation
  cert_path       = "" # Leave empty if skipping SSL validation
  key_path        = "" # Leave empty if skipping SSL validation
  script_path     = "C:/Temp/terraform_%RAND%.cmd"
  timeout         = "30s"
}