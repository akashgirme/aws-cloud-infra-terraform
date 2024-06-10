resource "aws_autoscaling_group" "auto_scaling_group" {
  name             = "${var.environment}-auto-scaling-group"
  min_size         = var.auto_scaling_group_min_size
  max_size         = var.auto_scaling_group_max_size
  desired_capacity = var.auto_scaling_group_desired_capacity

  capacity_rebalance = true
  health_check_type = "ELB"
  health_check_grace_period = 25

  ## Time in seconds - configurable amount of time that Auto Scaling waits
  ## before considering a new instance as available for serving traffic.
  default_instance_warmup = 90
 
  launch_template {
    id      = var.launch_configuration.id
    version = var.launch_configuration.latest_version
  }

  vpc_zone_identifier = flatten([for subnet in var.private_subnets : subnet.id])
  termination_policies = ["OldestInstance", "OldestLaunchConfiguration"]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances",
    "GroupInServiceCapacity",
    "GroupTotalCapacity"
  ]

  metrics_granularity = "1Minute"

  target_group_arns = [var.lb_target_group.arn]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-ASG"
    propagate_at_launch = true
  }

  depends_on = [var.launch_configuration]
}


#---------CloudWatch Alarms for Scale-Down and Scale-Up-----------

# CloudWatch alarm for auto scaling up
# Triggers when Average CPU Utilization touch the threshold value
resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30" # Period for which CPU should hit threshold to trigger alarm
  statistic           = "Average"
  threshold           = var.auto_scale_in_cpu_threshold
  alarm_description   = "This metric checks for high CPU utilization"
  alarm_actions       = ["${aws_autoscaling_policy.auto_scaling_policy_scale_up.arn}"]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.auto_scaling_group.name
  }
  treat_missing_data = "missing"
}

# Attaching Scale-Up CloudWatch Alarm with Scale-Up Policy
resource "aws_autoscaling_policy" "auto_scaling_policy_scale_up" {
  name                   = "auto_scaling_policy/Scale-In"
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
}


# CloudWatch alarm for auto scaling down
# Triggers when Average CPU Utilization touch the threshold value
resource "aws_cloudwatch_metric_alarm" "cpu_low_alarm" {
  alarm_name          = "cpu-low-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "1200"  # Period for which CPU should hit threshold to trigger alarm
  statistic           = "Average"
  threshold           = var.auto_scale_out_cpu_threshold
  alarm_description   = "This metric checks for low CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.auto_scaling_policy_scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.auto_scaling_group.name
  }
  treat_missing_data = "missing"
}

# Attaching Scale-Down CloudWatch Alarm with Scale-Down Policy
resource "aws_autoscaling_policy" "auto_scaling_policy_scale_down" {
  name                   = "auto_scaling_policy/Scale-Out"
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1 # Adjust this value as needed
  cooldown               = 60
}


resource "aws_autoscaling_traffic_source_attachment" "traffic_source" {
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.name

  traffic_source {
    identifier = var.lb_target_group.arn
    type       = "elbv2"
  }
}


resource "aws_autoscaling_notification" "autoscaling_notifications" {
  group_names = [
    aws_autoscaling_group.auto_scaling_group.name
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.asg_sns_topic.arn
}

resource "aws_sns_topic" "asg_sns_topic" {
  name = "AutoScalingGroup-sns-topic"
}
