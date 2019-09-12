locals {
  state_file = "${md5(file("${path.module}/configuration/top.sls"))}"
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

resource "null_resource" "default" {
  count = "${length(var.hosts)}"

  triggers = {
    top_file = "${local.state_file}"
  }

  connection {
    type        = "ssh"
    user        = "${var.ssh_username}"
    private_key = "${var.ssh_private_key}"
    host        = "${var.hosts[count.index]}"
  }

  provisioner "file" {
    source      = "${path.module}/configuration/top.sls"
    destination = "/tmp/top.sls"
  }

  provisioner "remote-exec" {
    inline = [
      "set -eou pipefail",
      "if [ ! -d /srv/salt ]; then",
      "  sudo mkdir -p /srv/salt",
      "elif [ -f /srv/salt/top.sls ]; then",
      "  sudo rm /srv/salt/top.sls",
      "fi",
      "sudo mv /tmp/top.sls /srv/salt/top.sls",
    ]
  }

  depends_on = [
    null_resource.waited_on
  ]
}
