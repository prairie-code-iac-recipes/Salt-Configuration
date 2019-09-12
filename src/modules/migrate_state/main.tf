locals {
  state_file = "${md5(file("${path.module}/configuration/${var.package_name}/init.sls"))}"
}

###############################################################################
# Used to Enable Inter-Module Dependency
###############################################################################
resource "null_resource" "waited_on" {
  count = "${length(var.wait_on)}"

  provisioner "local-exec" {
    command = "echo Dependency ${count.index + 1} of ${length(var.wait_on)} Resolved: ${var.wait_on[count.index]}"
  }
}

###############################################################################
# Migrate State Files for Specific Packages
###############################################################################
resource "null_resource" "default" {
  count = "${length(var.hosts)}"

  triggers = {
    state_file = "${local.state_file}"
  }

  connection {
    type        = "ssh"
    user        = "${var.ssh_username}"
    private_key = "${var.ssh_private_key}"
    host        = "${var.hosts[count.index]}"
  }

  provisioner "remote-exec" {
    inline = [
      "set -eou pipefail",
      "mkdir -p /tmp/${var.package_name}",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/configuration/${var.package_name}/"
    destination = "/tmp/${var.package_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "set -eou pipefail",
      "if [ -d /srv/salt/${var.package_name} ]; then",
      "  sudo rm -rf /srv/salt/${var.package_name}",
      "fi",
      "sudo mv /tmp/${var.package_name} /srv/salt",
    ]
  }

  depends_on = [
    null_resource.waited_on
  ]
}
