
resource "aws_codedeploy_app" "codedeploy_app" {
  name             = "CodeDeployApplication"
  compute_platform = "Server"

}


resource "aws_sns_topic" "sns_topic_in_code_deploy" {
  name = "${var.environment}-codedeploy-sns-topic"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "sns:Publish",
        "Resource" : "arn:aws:sns:us-east-1:851725253738:production-codedeploy-sns-topic",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:sns:us-east-1:851725253738:production-codedeploy-sns-topic"
          }
        }
      }
    ]
  })
}


resource "aws_codedeploy_deployment_config" "code_deploy_config" {
  deployment_config_name = "EC2AllAtOnce"

  compute_platform = "Server"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 0
  }

}


resource "aws_codedeploy_deployment_group" "codedeploy_deployment_group" {
  app_name              = aws_codedeploy_app.codedeploy_app.name
  deployment_group_name = "${var.environment}-code-deployment-group"

  autoscaling_groups = [var.auto_scaling_group.name]
  service_role_arn   = aws_iam_role.CodeDeployIAMRole.arn

  trigger_configuration {
    trigger_events = ["DeploymentFailure", "DeploymentSuccess", "DeploymentStop",
    "InstanceStart", "InstanceSuccess", "InstanceFailure"]
    trigger_name       = "CodeDeploy-event-trigger"
    trigger_target_arn = aws_sns_topic.sns_topic_in_code_deploy.arn
  }

  alarm_configuration {
    alarms  = ["${var.environment}-codedeploy-alarm"]
    enabled = true
  }


  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "STOP_DEPLOYMENT" # 'CONTINUE_DEPLOYMENT'/'STOP_DEPLOYMENT'

      # 'CONTINUE_DEPLOYMENT' - Register new instances with the load balancer immediately
      # after the new application revision is installed on the instances in the replacement environment.

      # 'STOP_DEPLOYMENT' - Do not register new instances with load balancer unless traffic is rerouted manually.
      # If traffic is not rerouted manually before the end of the specified wait period, the deployment status is changed to Stopped.

      wait_time_in_minutes = 60

      # Wait_time period required on 'STOP_DEPLOYMENT' action. Specify time to wait for manual traffic rerouting.
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.termination_wait_time_in_minutes # Termination wait time is in minute
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM", "DEPLOYMENT_STOP_ON_REQUEST"]
  }


  load_balancer_info {
    target_group_info {
      name = var.lb_target_group.name
    }
  }
}

resource "aws_iam_role_policy" "CodeDeploy_policy" {
  name = "CodeDeploy_policy"
  role = aws_iam_role.CodeDeployIAMRole.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_role" "CodeDeployIAMRole" {
  name = "CodeDeployIAMRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codedeploy.amazonaws.com"
        },
        "Action" : ["sts:AssumeRole"]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  role       = aws_iam_role.CodeDeployIAMRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role_policy_attachment" "SNSPublishPolicy" {
  role       = aws_iam_role.CodeDeployIAMRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}