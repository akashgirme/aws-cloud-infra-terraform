locals {
  user_data_file = "${path.module}/user-data.sh"
  user_data_b64  = base64encode(file(local.user_data_file))
}


resource "aws_launch_template" "launch_template" {
  name          = "${var.environment}-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  update_default_version = true

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }


  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }


  credit_specification {
    cpu_credits = "standard"
  }

  ebs_optimized = true

  instance_initiated_shutdown_behavior = "terminate"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    security_groups       = [var.security_group.id]
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = var.environment,
      Environment = var.environment
    }
  }


  iam_instance_profile {
    name = aws_iam_instance_profile.launch_template_iam_instance_profile.name
  }

  user_data = local.user_data_b64
}

# IAM role for ec2 instance/launch template
resource "aws_iam_role" "launch_template_role" {
  name = "launch_template_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Resources for policy Attachment
resource "aws_iam_instance_profile" "launch_template_iam_instance_profile" {
  name = "Ec2-launch-template"
  role = aws_iam_role.launch_template_role.name

}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  role       = aws_iam_role.launch_template_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "AutoScalingNotificationAccessRole" {
  role       = aws_iam_role.launch_template_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRole"
}

resource "aws_iam_role_policy_attachment" "SecretsManagerReadWrite" {
  role       = aws_iam_role.launch_template_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy" {
  role       = aws_iam_role.launch_template_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}



