output "trigger" {
  value       = "${local.state_file}"
  description = "Used to trigger highstate in main.tf file."
}

output "wait_on" {
  description = "This output can be passed in another module's waited_on input to force an inter-module dependency."
  value       = "Top Successfully Migrated"
  depends_on  = [
    null_resource.default
  ]
}
