locals {
  sfn = {
    user-register = {
      definition = <<EOF
      {
        "Comment": "A description of my state machine",
        "StartAt": "Lambda Invoke",
        "TimeoutSeconds": 10,
        "States": {
          "Lambda Invoke": {
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "OutputPath": "$.Payload",
            "Parameters": {
              "Payload.$": "$",
              "FunctionName":  "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.account_id.account_id}:function:${var.environment}-user-register-user-backgroud-process:$LATEST"
            },
            "Retry": [
              {
                "ErrorEquals": [
                  "Lambda.ServiceException",
                  "Lambda.AWSLambdaException",
                  "Lambda.SdkClientException",
                  "Lambda.TooManyRequestsException"
                ],
                "IntervalSeconds": 1,
                "MaxAttempts": 3,
                "BackoffRate": 2
              }
            ],
            "End": true
          }
        }
      }
    EOF
    }
  }
}
