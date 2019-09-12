###############################################################################
# Setup
###############################################################################
provider "aws" {
  version = "~> 2.23"
  region  = "us-east-1"
}

provider "null" {
  version = "~> 2.1"
}

terraform {
  backend "s3" {
    bucket         = "com.iac-example"
    key            = "salt-configuration"
    region         = "us-east-1"
    dynamodb_table = "terraform-statelock"
  }
}

###############################################################################
# Local Variables
###############################################################################
locals {
  ssh_private_key = "${base64decode(var.ssh_private_key)}"
}

###############################################################################
# Deploy All Saltmaster Artifacts
###############################################################################
module "migrate_top" {
  source = "./modules/migrate_top"

  hosts             = "${var.hosts}"
  ssh_username      = "${var.ssh_username}"
  ssh_private_key   = "${local.ssh_private_key}"
}

module "migrate_all_states" {
  source = "./modules/migrate_all_states"

  hosts             = "${var.hosts}"
  ssh_username      = "${var.ssh_username}"
  ssh_private_key   = "${local.ssh_private_key}"
}

resource "null_resource" "highstate" {
  count = "${length(var.hosts) > 0 ? 1 : 0}"

  triggers = {
    top_change   = "${module.migrate_top.trigger}"
    state_change = "${module.migrate_all_states.trigger}"
  }

  connection {
    type        = "ssh"
    user        = "${var.ssh_username}"
    private_key = "${local.ssh_private_key}"
    host        = "${var.hosts[count.index]}"
  }

  provisioner "remote-exec" {
    inline = [
      "set -eou pipefail",
      "sudo salt '*' state.apply"
    ]
  }

  depends_on = [
    module.migrate_top,
    module.migrate_all_states
  ]
}

