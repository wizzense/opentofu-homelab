# Example

Looks like we can use a remote hyperv host, and not just a local one.

```tofu
# Configure HyperV
provider "hyperv" {
  user            = "Administator"
  password        = "P@ssw0rd"
  host            = "127.0.0.1"
  port            = 5986
  https           = true
  insecure        = false
  use_ntlm        = true
  tls_server_name = ""
  cacert_path     = ""
  cert_path       = ""
  key_path        = ""
  script_path     = "C:/Temp/terraform_%RAND%.cmd"
  timeout         = "30s"
}

# Create a switch
resource "hyperv_network_switch" "dmz" {
}

# Create a vhd
resource "hyperv_vhd" "webserver" {
}

# Create a machine
resource "hyperv_machine_instance" "webserver" {
}
```

## Optional

```tofu

- `cacert_path` (String): The path to the ca certificates to use for HyperV api calls. Can also be sourced from the HYPERV_CACERT_PATH environment variable otherwise defaults to empty string.
- `cert_path` (String): The path to the certificate to use for authentication for HyperV api calls. Can also be sourced from the HYPERV_CERT_PATH environment variable otherwise defaults to empty string.
- `host` (String): The host to run HyperV api calls against. It can also be sourced from the HYPERV_HOST environment variable otherwise defaults to 127.0.0.1.
- `https` (Boolean): Should https be used for HyperV api calls. It can also be sourced from HYPERV_HTTPS environment variable otherwise defaults to true.
- `insecure` (Boolean): Skips TLS Verification for HyperV api calls. Generally this is used for self-signed certificates. Should only be used if absolutely needed. Can also be set via setting the HYPERV_INSECURE environment variable to true otherwise defaults to false.
- `kerberos_config` (String): Use Kerberos Config for authentication for HyperV api calls. Can also be set via setting the HYPERV_KERBEROS_CONFIG or KRB5_CONFIG environment variable otherwise defaults to /etc/krb5.conf.
- `kerberos_credential_cache` (String): Use Kerberos Credential Cache for authentication for HyperV api calls. Can also be set via setting the HYPERV_KERBEROS_CREDENTIAL_CACHE or KRB5CCNAME environment variable otherwise defaults to empty string.
- `kerberos_realm` (String): Use Kerberos Realm for authentication for HyperV api calls. Can also be set via setting the HYPERV_KERBEROS_REALM environment variable otherwise defaults to empty string.
- `kerberos_service_principal_name` (String): Use Kerberos Service Principal Name for authentication for HyperV api calls. Can also be set via setting the HYPERV_KERBEROS_SERVICE_PRINCIPAL_NAME environment variable otherwise defaults to empty string.
- `key_path` (String): The path to the certificate private key to use for authentication for HyperV api calls. Can also be sourced from the HYPERV_KEY_PATH environment variable otherwise defaults to empty string.
- `password` (String): The password associated with the username to use for HyperV api calls. It can also be sourced from the HYPERV_PASSWORD environment variable.
- `port` (Number): The port to run HyperV api calls against. It can also be sourced from the HYPERV_PORT environment variable otherwise defaults to 5986.
- `script_path` (String): The path used to copy scripts meant for remote execution for HyperV api calls. Can also be sourced from the HYPERV_SCRIPT_PATH environment variable otherwise defaults to C:/Temp/terraform_%RAND%.cmd.
- `timeout` (String): The timeout to wait for the connection to become available for HyperV api calls. Should be provided as a string like 30s or 5m. Can also be sourced from the HYPERV_TIMEOUT environment variable otherwise defaults to 30s.
- `tls_server_name` (String): The TLS server name for the host used for HyperV api calls. Can also be sourced from the HYPERV_TLS_SERVER_NAME environment variable otherwise defaults to empty string.
- `use_ntlm` (Boolean): Use NTLM for authentication for HyperV api calls. Can also be set via setting the HYPERV_USE_NTLM environment variable to true otherwise defaults to true.
- `user` (String): The username to use when HyperV api calls are made. Generally this is Administrator. It can also be sourced from the HYPERV_USER environment variable otherwise defaults to Administrator.
```
