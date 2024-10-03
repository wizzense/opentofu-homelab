
# Getting Started with OpenTofu

## Basic OpenTofu Workflow

### 1. Write

- **Create a Repository**: Initialize a Git repository to version control your infrastructure code.

  ```bash
  git init my-infra && cd my-infra
  ```

- **Write Configuration**: Create and edit your OpenTofu configuration files (e.g., `main.tf`) in your preferred code editor.

  ```bash
  vim main.tf
  ```

- **Initialize OpenTofu**: Set up OpenTofu for your project, initializing necessary provider plugins.

  ```bash
  tofu init
  ```

### 2. Plan

- **Review Configuration**: Run iterative `tofu plan` commands to ensure your configuration is error-free and as expected.

  ```bash
  tofu plan
  ```

- **Commit Changes**: Once satisfied, commit your configuration changes to the repository.

  ```bash
  git add main.tf
  git commit -m 'Managing infrastructure as code!'
  ```

### 3. Apply

- **Provision Infrastructure**: Run the `tofu apply` command to provision the infrastructure. Review the plan and confirm the actions.

  ```bash
  tofu apply
  ```

  - Confirm with `yes` when prompted to apply the changes.

- **Push to Remote Repository**: Optionally, push your changes to a remote Git repository for safekeeping.

  ```bash
  git remote add origin https://github.com/*user*/*repo*.git
  git push origin main
  ```

## Working as a Team

- **Branching**: Work on feature branches to avoid conflicts.

  ```bash
  git checkout -b add-feature
  ```

- **Collaborate via CI**: Use a Continuous Integration (CI) environment to run OpenTofu operations and manage sensitive inputs securely.
- **Review & Merge**: Use pull requests for team reviews, including speculative plan outputs, and merge only after approvals.

## Conclusion

- **Repeat the Workflow**: This core workflow (Write → Plan → Apply) is iterative and will be repeated for each change in your infrastructure code.
- **Scale with TACOS**: For organizations, consider using TACOS to extend this workflow for more complex, collaborative environments.
