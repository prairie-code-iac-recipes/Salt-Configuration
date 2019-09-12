output "trigger" {
  value       = "${module.docker.trigger}"
  description = "Used to trigger highstate in main.tf file."
}

output "wait_on" {
  description = "This output can be passed in another module's waited_on input to force an inter-module dependency."
  value       = "${module.docker.wait_on}"
}
