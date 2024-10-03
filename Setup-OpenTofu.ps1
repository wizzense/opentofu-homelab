<#
Write

You write OpenTofu configuration just like you write code: in your editor of choice. 
It's common practice to store your work in a version-controlled repository even when you're just operating as an individual.
#>

# Create repository in the script's directory and navigate to it
$repoPath = Join-Path -Path $PSScriptRoot -ChildPath "my-infra"
New-Item -ItemType Directory -Path $repoPath -Force | Out-Null
Set-Location -Path $repoPath

# Initialize OpenTofu
tofu init

# Ensure that a configuration file exists before proceeding
$configFilePath = Join-Path -Path $repoPath -ChildPath "main.tf"

if (-Not (Test-Path -Path $configFilePath)) {
    Write-Host "Error: No configuration file found at $configFilePath"
    Write-Host "Please create a configuration file (e.g., main.tf) before running the plan or apply steps."
    exit 1
}

<#
As you make progress on authoring your config, repeatedly running plans 
can help flush out syntax errors and ensure that your config is coming together as you expect.
#>

# Review plan
tofu plan

<#
Plan

When the feedback loop of the Write step has yielded a change that looks good, it's time to commit your work and review the final plan.
#>

# Initialize Git repository if it's not already initialized
if (-Not (Test-Path -Path "$repoPath\.git")) {
    git init
}

git add main.tf
git commit -m 'Managing infrastructure as code!'

<#
Because tofu apply will display a plan for confirmation before proceeding to change any infrastructure, that's the command you run for final review.
#>

tofu apply

<#Do you want to perform these actions?

    OpenTofu will perform the actions described above.
    Only 'yes' will be accepted to approve.
    Enter a value: yes
#>
# ...

#Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

<#
At this point, it's common to push your version control repository to a remote location for safekeeping.
#>

git remote add origin https://github.com/*user*/*repo*.git
git push origin main
