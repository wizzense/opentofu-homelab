# How OpenTofu Works with Hyper-V

## Local Execution

OpenTofu, in the context of Hyper-V, runs locally on a machine that already has Hyper-V installed and configured. It does not install Hyper-V itself; it assumes that Hyper-V is already installed and operational.

## Interacting with Hyper-V

When you define resources like virtual machines in OpenTofu, it uses the Hyper-V provider plugin to communicate with the local Hyper-V instance. It issues commands to Hyper-V to create VMs, configure networking, and manage other resources as described in your .tf files.

## Prerequisites for Using OpenTofu with Hyper-V

### Hyper-V Must Be Pre-installed

Hyper-V must already be installed on the machine where you intend to run OpenTofu. This machine is typically a Windows Server or a Windows client OS like Windows 10 or Windows 11 that has the Hyper-V role enabled.

### Local Execution Context

OpenTofu will look for the Hyper-V instance on the local machine (the one you are running tofu commands on). It does not manage remote Hyper-V servers directly (unless you’re using some form of scripting or remoting within the OpenTofu process, but that’s more complex and not typically how OpenTofu is used).

## Workflow Overview

Here’s how the typical workflow with OpenTofu and Hyper-V would look:

1. Set Up Your Machine with Hyper-V:
    - Install Hyper-V on your Windows machine.
    - Ensure that Hyper-V is configured and working properly (you should be able to manually create VMs through the Hyper-V Manager).

2. Install OpenTofu on the Same Machine:
    - Download and install OpenTofu on the same machine where Hyper-V is running.
    - Configure OpenTofu to use the Hyper-V provider by defining the necessary provider block in your .tf files.

3. Write Your OpenTofu Configuration:
    - Write .tf files to describe the VMs and other resources you want to create.
    - These configurations will directly control Hyper-V through the provider plugin.

4. Initialize and Apply Configuration:
    - Run `tofu init` to initialize the configuration and download necessary providers.
    - Run `tofu plan` to see what changes will be made.
    - Run `tofu apply` to create the VMs on your local Hyper-V instance.

## Example: Setting Up Your Environment

Let’s go through a more concrete example.

**Step 1: Install Hyper-V**
Enable Hyper-V on Windows 10/11:

1. Open PowerShell as Administrator.
2. Run the following command to enable the Hyper-V feature:

    ```
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    ```

3. Reboot your computer if prompted.

Verify Hyper-V Installation:

1. Open the Hyper-V Manager from the Start menu.
2. Ensure you can create and manage VMs manually to verify Hyper-V is working.

**Step 2: Install OpenTofu**
Download OpenTofu:

- Visit the OpenTofu GitHub releases page and download the appropriate binary for your operating system.

Install OpenTofu:

- Extract the binary and add it to your system’s PATH to make the `tofu` command available from the command line.

**Step 3: Write OpenTofu Configuration Files**
Create a directory for your project, e.g., `my-hyperv-vms`.
Inside this directory, create .tf files as described earlier (e.g., `provider.tf`, `vm.tf`, `variables.tf`).

Here’s a basic setup:

`provider.tf`:

```hcl
terraform {
  required_providers {
     hyperv = {
        source  = "hashicorp/hyperv"
        version = "~> 0.1"
     }
  }
}

provider "hyperv" {
  # Default settings, assuming local Hyper-V instance
}
```

`vm.tf`:

```hcl
resource "hyperv_virtual_machine" "my_vm" {
  name              = "TestVM"
  generation        = 2
  memory_mb         = 2048
  virtual_processor = 2
  
  disk {
     size_gb   = 20
     vhdx_path = "${path.module}/disks/testvm.vhdx"
  }

  network_interface {
     name = "Default Switch"
  }

  automatic_start_action = "start_if_running"
}
```

**Step 4: Apply the Configuration**
Initialize OpenTofu:

In your terminal, navigate to your project directory and run:

```
tofu init
```

Plan the Deployment:

See what OpenTofu will do:

```
tofu plan
```

Apply the Configuration:

Create the VM on Hyper-V:

```
tofu apply
```

**Step 5: Verify the VM in Hyper-V**
Open Hyper-V Manager and check that the VM defined in your .tf files has been created.

## Key Takeaways

- OpenTofu Requires an Existing Hyper-V Installation: OpenTofu doesn’t install Hyper-V; it interacts with an existing Hyper-V instance on the local machine.
- Local Execution Context: It assumes that you are running OpenTofu commands on the same machine where Hyper-V is installed.
- Infrastructure as Code: The .tf files describe the infrastructure (like VMs) you want to create, and OpenTofu automates the creation and management of these resources by communicating with Hyper-V.
- By ensuring that Hyper-V is set up before you start using OpenTofu, you can effectively automate the creation and management of VMs using infrastructure as code principles.
