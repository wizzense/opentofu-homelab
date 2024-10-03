# Define the directory where the configuration file will be placed
$configDir = "$HOME/.opentofu.d"
$configFilePath = Join-Path -Path $configDir -ChildPath "config.tfrc"

# Ensure the directory exists
if (-Not (Test-Path -Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

# Define the content of the CLI configuration file
$configContent = @"
provider_installation {
  filesystem_mirror {
    path    = "$HOME/.opentofu.d/plugins"
    include = ["example.com/*/*"]
  }
  direct {
    exclude = ["example.com/*/*"]
  }
}

plugin_cache_dir = "$HOME/.opentofu.d/plugin-cache"
"@

# Write the configuration content to the file
Set-Content -Path $configFilePath -Value $configContent

Write-Host "OpenTofu CLI configuration file has been created at $configFilePath"
