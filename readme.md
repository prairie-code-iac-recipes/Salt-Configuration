# Salt Configuration Repository
## Purpose
The purpose of this project is to centralize Salt state, grain, and package management. By separating the Salt configuration into its own repository we are able to leverage it in two ways.  First, system engineers can modify state, grain, and package definitions and deploy the updated state and grain information to the salt masters.  Second, new server provisioning processes written in Terraform can reference this repository as a module and use it to establish their salt role and get the associated software installed.

## Branching Model
### Overview
This repository contains definitions that need to follow an organization's environment model with changes deployed to non-production environments and tested before being deployed to the production environment.  One way to manage this would be to create permanent branches that represent each of the environments in the environment such as development, test, and production. Following this approach would allow us to deploy to the corresponding envionment as changes were merged from the development branch to the test branch and then finally to the production branch.  Alternatively we could use tagging and allow the individual server provisioning processes to reference a specific tag in their module definition.  There are undoubtedly other options as well.  In this case I have chosen to implement the previously-mentioned branch-based deployment model.

### Detail
1. Modifications are made to feature branches created from the development branch.
2. Feature branches are then merged into the development branch via pull-request.
3. The development branch will automatically deploy to the development environment's saltmaster when updated.
4. Once the change has been tested in the development environment, they can be merged into the production branch.
5. The production branch will automatically deploy to the production environment's saltmaster when updated.

## Pipeline
1. All Terraform files will be validated whenever any branch is updated.
2. A Terraform Plan is run and the plan persisted whenever the development or production branches change.
3. A Terraform Apply is run for the persisted plan whenever the development or production branches change.

## Terraform
## Inputs
| Variable | Description |
| -------- | ----------- |
| hosts | A list of DNS names and/or IP addresses for individual saltmaster instances. |
| ssh_username | The user that we should use for ssh connections.
| ssh_private_key | The contents of a base64-encoded SSH private key to use for the connection. |

## Processing
Each of the submodules can be referenced seperately and used to publish the top and state files to saltmaster instances or to publish a role-specific grains file to other server types that are also salt minions.  However, if this job is run from the root main.tf file (as it is via the Gitlab CI process) then it will perform the following.
1. Migrate the salt "top" file to /srv/salt on each of the specified salt master hosts.
2. Migrate the salt state files to /srv/salt/package-name on each of the specified salt master hosts.
3. Run high state to publish updates to all minions.

## Outputs
None
