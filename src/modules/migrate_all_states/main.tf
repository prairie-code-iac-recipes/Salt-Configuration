###############################################################################
# Migrate All Packages (there is currently only one)
###############################################################################
module "docker" {
  source = "../migrate_state"

  package_name    = "docker-package"
  hosts           = "${var.hosts}"
  ssh_username    = "${var.ssh_username}"
  ssh_private_key = "${var.ssh_private_key}"

  wait_on = "${var.wait_on}"
}
