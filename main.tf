resource "aws_cloudwatch_log_group" "aws_cloudwatch_log_group" {
  for_each          = local.sfn
  name              = "${var.environment}-sfn-${each.key}"
  retention_in_days = 7
}

resource "aws_iam_role" "aws_iam_role" {
  name               = "${var.environment}-sfn-role-${data.terraform_remote_state.vpc.outputs.random_id}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "aws_iam_policy" {
  name        = "${var.environment}-sfn-policy-${data.terraform_remote_state.vpc.outputs.random_id}"
  path        = "/"
  description = "${var.environment}-sfn-policy-${data.terraform_remote_state.vpc.outputs.random_id}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Effect = "Allow"
        Resource : "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment" {
  policy_arn = aws_iam_policy.aws_iam_policy.arn
  role       = aws_iam_role.aws_iam_role.name
}


resource "aws_sfn_state_machine" "sfn_state_machine" {
  depends_on = [aws_cloudwatch_log_group.aws_cloudwatch_log_group, aws_iam_role_policy_attachment.aws_iam_role_policy_attachment]
  for_each   = local.sfn
  name       = "${var.environment}-sfn-${each.key}"
  role_arn   = aws_iam_role.aws_iam_role.arn
  definition = each.value.definition
  tracing_configuration {
    enabled = true
  }
  logging_configuration {
    include_execution_data = false
    log_destination        = "${aws_cloudwatch_log_group.aws_cloudwatch_log_group[each.key].arn}:*"
    level                  = "ALL"
  }
}
