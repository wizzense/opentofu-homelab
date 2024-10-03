# What OpenTofu Does

OpenTofu: Infrastructure as Code (IaC) Tool

OpenTofu is an Infrastructure as Code (IaC) tool. This means you define what your infrastructure should look like in configuration files, and OpenTofu takes those definitions and makes them a reality by interacting with the relevant cloud or virtualization providers (like Hyper-V, AWS, etc.).

## How OpenTofu Builds VMs on Hyper-V

### Define the Provider

The provider tells OpenTofu which platform it should be interacting with. In this case, it's Hyper-V, so you'll define the Hyper-V provider.

### Describe the VM Resources

You describe the VMs you want to create using resources within the .tf files. These resources include all the details needed to create the VMs, like name, memory, CPUs, disk size, and network interfaces.

### Apply the Configuration

OpenTofu takes the configurations you’ve described and applies them to the Hyper-V environment. This means it will interact with Hyper-V to create the VMs according to the specifications you’ve provided.

## Step-by-Step Example: Building VMs with OpenTofu on Hyper-V

Let’s go through an example of how to build a VM using OpenTofu on Hyper-V.

1. Install OpenTofu and the Hyper-V Provider
First, ensure OpenTofu is installed on your system, along with the necessary provider plugin for Hyper-V.

2. Create Your Configuration Files
Let’s create a few key files in a directory, say my-homelab/, where you will define the infrastructure.

- provider.tf (sets up the provider)
- variables.tf (defines input variables)
- vm.tf (defines the VM resource)
- outputs.tf (provides output information after creation)

3. Initialize the OpenTofu Project
In your terminal, navigate to the directory containing your .tf files (my-homelab/) and run:

```tf
tofu init
```

This command will initialize the project and download the required provider plugins.

4. Preview the Changes
Before actually creating the VM, you can preview what OpenTofu will do by running:

```tf
tofu plan
```

This command outputs a detailed plan showing which resources will be created, modified, or destroyed. Since this is the first time, you should see that OpenTofu plans to create a new VM.

5. Apply the Configuration
Once you're satisfied with the plan, apply the configuration to create the VM:

```tf
tofu apply
```

You’ll be prompted to confirm. Type yes, and OpenTofu will begin creating the VM in Hyper-V according to your configuration.

6. Check the VM
Once the process is complete, you can open the Hyper-V Manager on your machine to see the newly created VM. The VM will have the name, CPU, memory, disk size, and network configuration you specified.

## Integrating Ansible

Once the VM is created using OpenTofu, you might want to configure it further using Ansible. Here’s how that fits in:

- Generate an Ansible Inventory: After the VMs are created, you can extract their IPs and generate an Ansible inventory file.
- Run Ansible Playbooks: Use Ansible to SSH into the newly created VMs and configure them (e.g., installing software, setting up services).

## Summary

OpenTofu allows you to automate the creation of VMs by defining the desired state in configuration files. You write .tf files that describe the resources you want, such as VMs, networks, and storage. Ansible is then used for post-deployment configuration, allowing you to further automate the setup and management of your VMs. By combining OpenTofu and Ansible, you get a powerful setup for both provisioning infrastructure and managing configurations, all in a repeatable, automated fashion.
