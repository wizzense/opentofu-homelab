# Set Up OpenTofu Environment

## Install OpenTofu

1. Download and install OpenTofu for your operating system from the [OpenTofu releases page](https://github.com/opentofu/opentofu/releases).
2. Add OpenTofu to your system's PATH to make the `tofu` command available globally.

## Install the Hyper-V Provider Plugin

1. OpenTofu requires provider plugins to interact with specific platforms like Hyper-V. You’ll need to install the Hyper-V provider plugin.
2. Add the following block in your configuration to install the Hyper-V provider:

```hcl
terraform {
    required_providers {
        hyperv = {
            source = "Microsoft/hyperv"
            version = "~> 0.1"  # Replace with the latest stable version
        }
    }
}
```

## Define Configuration Files for Your Infrastructure

Configuration files in OpenTofu are written in HashiCorp Configuration Language (HCL). You'll need to create `.tf` files that define your infrastructure. For your home lab setup, you’ll likely need several key components:

### Provider Configuration (`provider.tf`)

This tells OpenTofu to use the Hyper-V provider.

```hcl
provider "hyperv" {
    # Optional: specify the Hyper-V server (default is the local machine)
    # server = "hyperv.local"
}
```

## Network Configuration with OpenTofu

For your Hyper-V VMs, networking can involve creating and managing virtual switches, assigning IP addresses, and configuring network interfaces. OpenTofu, using the Hyper-V provider, allows you to define these networking components.

### Define a Virtual Switch

First, you'll need to define a virtual switch that your VMs can connect to. This can be done using a combination of PowerShell and OpenTofu, as the Hyper-V provider might not directly support all networking features out-of-the-box.

```hcl
resource "hyperv_virtual_switch" "lab_switch" {
    name       = "LabSwitch"
    type       = "Internal"
    adapter    = "Ethernet"
}
```

Note: The `hyperv_virtual_switch` resource might need custom scripting since the official OpenTofu Hyper-V provider may not support this directly. You might need to create the switch manually using PowerShell or wrap this in a script that OpenTofu calls.

### Assign Network Interfaces to VMs

After defining the virtual switch, assign network interfaces for each VM to connect them to this switch.

```hcl
resource "hyperv_virtual_machine" "control_node" {
    name              = var.control_node_name
    generation        = 2
    memory_mb         = 4096
    virtual_processor = 2
    disk {
        size_gb = 60
        vhdx_path = "${path.module}/disks/control_node.vhdx"
    }
    network_interface {
        name        = hyperv_virtual_switch.lab_switch.name
        mac_address = "00:15:5D:00:00:01"
    }
    automatic_start_action = "start_if_running"
}

resource "hyperv_virtual_machine" "secondary_node" {
    name              = var.secondary_node_name
    generation        = 2
    memory_mb         = 4096
    virtual_processor = 2
    disk {
        size_gb = 60
        vhdx_path = "${path.module}/disks/secondary_node.vhdx"
    }
    network_interface {
        name        = hyperv_virtual_switch.lab_switch.name
        mac_address = "00:15:5D:00:00:02"
    }
    automatic_start_action = "start_if_running"
}
```

### VM Definition (`vm.tf`)

Define each VM you want to create. You can parameterize VM configurations using variables.

```hcl
resource "hyperv_virtual_machine" "control_node" {
    name              = var.control_node_name
    generation        = 2
    memory_mb         = 4096
    virtual_processor = 2
    disk {
        size_gb = 60
        vhdx_path = "${path.module}/disks/control_node.vhdx"
    }
    network_interface {
        name = "Default Switch"
    }
    automatic_start_action = "start_if_running"
}

resource "hyperv_virtual_machine" "secondary_node" {
    name              = var.secondary_node_name
    generation        = 2
    memory_mb         = 4096
    virtual_processor = 2
    disk {
        size_gb = 60
        vhdx_path = "${path.module}/disks/secondary_node.vhdx"
    }
    network_interface {
        name = "Default Switch"
    }
    automatic_start_action = "start_if_running"
}
```

### Variables Configuration (`variables.tf`)

Define variables to make your configuration more flexible and reusable.

```hcl
variable "control_node_name" {
    description = "The name of the control node VM"
    type        = string
    default     = "ControlNode"
}

variable "secondary_node_name" {
    description = "The name of the secondary node VM"
    type        = string
    default     = "SecondaryNode"
}

variable "hyperv_server" {
    description = "The Hyper-V server (if remote)"
    type        = string
    default     = "localhost"
}
```

### Output Configuration (`outputs.tf`)

Output useful information after deployment.

```hcl
output "control_node_ip" {
    description = "IP address of the Control Node VM"
    value       = hyperv_virtual_machine.control_node.ip_address
}

output "secondary_node_ip" {
    description = "IP address of the Secondary Node VM"
    value       = hyperv_virtual_machine.secondary_node.ip_address
}
```

## Plan and Apply Your Infrastructure

1. Initialize the Project:
     In the directory containing your `.tf` files, run:

     ```bash
     tofu init
     ```

     This command will download and install the Hyper-V provider plugin.

2. Create a Plan:
     Before applying changes, you can see what OpenTofu plans to do by running:

     ```bash
     tofu plan
     ```

     This will output the actions that OpenTofu will take based on your configuration files.

3. Apply the Configuration:
     Once you're satisfied with the plan, apply the configuration to provision your infrastructure:

     ```bash
     tofu apply
     ```

     Confirm the apply action when prompted. OpenTofu will then create your VMs on the specified Hyper-V server.

## Expand and Customize

1. Add Additional Resources:
     You can add more resources such as additional VMs, networking components, or even scripts to be run post-VM creation (like configuring Tanium client installations).

2. Use Modules for Reusability:
     As your configuration grows, consider breaking it into modules for better organization and reuse. For example, you might create a module for a standard VM configuration and reuse it across different VMs with different parameters.

## Version Control and Collaboration

1. Store Configuration in Git:
     Use Git to version control your OpenTofu configuration files. This makes it easy to track changes, collaborate with others, and rollback if necessary.

2. CI/CD Integration:
     Consider integrating OpenTofu with a CI/CD pipeline to automate the deployment and updating of your home lab infrastructure.

## Example Directory Structure

Here’s how you might organize your OpenTofu configuration files:

```tree
homelab/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
└── modules/
        ├── vm/
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
```

## Next Steps

1. Explore Hyper-V Provider Documentation: Make sure to go through the Hyper-V provider documentation to understand all the available resources and options.

2. Experiment with Simple Configurations: Start with a basic configuration to get a feel for how OpenTofu works. Gradually add complexity as you become more comfortable.

3. Automation with Scripts: Consider automating the creation of `.tf` files if you plan on generating configurations for multiple VMs or more complex setups.

## Integrating with Ansible

Once the infrastructure is provisioned using OpenTofu, you can use Ansible for further configuration management. Ansible is particularly useful for tasks such as installing software, configuring services, and managing files on the VMs.

2.1 Install Ansible
First, make sure Ansible is installed on your control machine. If you're using a Linux-based system:

```bash
sudo apt-get update
sudo apt-get install ansible -y
```

For other OS types, refer to the Ansible installation guide.

2.2 Define an Inventory File
An Ansible inventory file lists the hosts that Ansible will manage. You can dynamically generate this inventory based on the output from OpenTofu.

Create an inventory file, say inventory.ini, where you'll add the VMs' IP addresses.

```ini
[control_nodes]
control_node ansible_host=192.168.1.10 ansible_user=admin ansible_password=your_password

[secondary_nodes]
secondary_node ansible_host=192.168.1.11 ansible_user=admin ansible_password=your_password
```

Alternatively, you can automate the generation of this file using the output from OpenTofu:

```bash
terraform output -json | jq -r '.control_node_ip.value, .secondary_node_ip.value' > inventory.ini
```

2.3 Create Ansible Playbooks
Create playbooks for configuring the VMs. For example, to install a web server on the control node VM:

```yaml
# playbook.yml
- hosts: control_nodes
  tasks:
    - name: Install Apache
      apt:
        name: apache2
        state: present

    - name: Start Apache service
      service:
        name: apache2
        state: started
```

2.4 Running Ansible Playbooks
Run the Ansible playbook against the control node:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

1. Integrate OpenTofu and Ansible in a Workflow
You can create a workflow that ties together OpenTofu and Ansible, allowing you to deploy and configure your infrastructure seamlessly.

3.1 Automate the Workflow with Scripts
Create a script that initializes your infrastructure with OpenTofu and then runs the Ansible playbooks:

```bash
#!/bin/bash

# Initialize and apply OpenTofu configuration
tofu init
tofu apply -auto-approve

# Extract the IPs from OpenTofu outputs and generate Ansible inventory
terraform output -json | jq -r '.control_node_ip.value, .secondary_node_ip.value' > inventory.ini

# Run Ansible Playbook
ansible-playbook -i inventory.ini playbook.yml
```

3.2 CI/CD Integration
Consider integrating this script into a CI/CD pipeline using tools like Jenkins, GitLab CI, or GitHub Actions. This would allow for automatic deployment and configuration whenever you update your OpenTofu or Ansible configurations.

1. Advanced Networking and Integration
If you want to manage more complex networking setups or additional configuration management, consider:

- Using Ansible Modules for Hyper-V: Ansible has modules for managing Hyper-V directly, which can be combined with OpenTofu for complex scenarios.
- VLAN and External Networking: For more complex networking, you might need to configure VLANs, set up external network adapters, or use different networking modes (e.g., external vs. internal) in Hyper-V. These can be handled either by PowerShell scripts or Ansible.

Example Combined Workflow
Here’s an example of how this could look in a real-world scenario:

1. Provision VMs with OpenTofu:
   - Configure networking and VMs using OpenTofu.
   - Generate necessary configuration files, including an inventory for Ansible.
2. Run Initial Setup with Ansible:
   - Use Ansible to install basic software, configure network settings, and prepare the VMs for use.
3. Ongoing Configuration Management:
   - Regularly use Ansible to apply updates, manage configurations, and deploy new software.
