output "sfn_arn" {
  value = zipmap(keys(local.sfn), [for arn in aws_sfn_state_machine.sfn_state_machine : arn.arn])
}

output "sfn_name" {
  value = zipmap(keys(local.sfn), [for id in aws_sfn_state_machine.sfn_state_machine : id.name])
}
