output "trigger" {
  value       = "${local.grains_file}"
  description = "Used to trigger salt minion to update state."
}

output "wait_on" {
  description = "This output can be passed in another module's waited_on input to force an inter-module dependency."
  value       = "Grains Successfully Migrated for ${var.role}"
  depends_on  = [
    null_resource.default
  ]
}
