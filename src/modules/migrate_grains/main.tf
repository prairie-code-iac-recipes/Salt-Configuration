locals {
  grains_file = "${md5(file("${path.module}/configuration/${var.role}/grains"))}"
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
# Migrate Grains File for Specific Server "Role"
###############################################################################
resource "null_resource" "default" {
  count = "${length(var.hosts)}"

  triggers = {
    grains_file = "${local.grains_file}"
  }

  connection {
    type        = "ssh"
    user        = "${var.ssh_username}"
    private_key = "${var.ssh_private_key}"
    host        = "${var.hosts[count.index]}"
  }

  provisioner "file" {
    source      = "${path.module}/configuration/${var.role}/grains"
    destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "set -eou pipefail",
      "if [ ! -f /etc/salt ]; then",
      "  sudo mkdir -p /etc/salt",
      "else",
      "  sudo rm /etc/salt/grains",
      "fi",
      "sudo cp -r /tmp/grains /etc/salt/grains",
      "sudo rm /tmp/grains",
    ]
  }

  depends_on = [
    null_resource.waited_on
  ]
}
