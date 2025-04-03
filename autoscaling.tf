# Auto Scaling Group
resource "aws_autoscaling_group" "webapp_asg" {
  name                = "csye6225_asg"
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.webapp_tg.arn]
  launch_template {
    id      = aws_launch_template.webapp.id
    version = "$Latest"
  }

  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period
  tag {
    key                 = "Name"
    value               = "${var.vpc_name}-asg-instance"
    propagate_at_launch = true
  }
}

# Scale Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = var.scale_up_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.cooldown
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = var.scale_down_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.cooldown
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

# CloudWatch Alarm for Scale Up
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-usage-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.scale_up_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.scale_up_period
  statistic           = "Average"
  threshold           = var.scale_up_threshold
  alarm_description   = "Scale up when CPU usage exceeds threshold"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}

# CloudWatch Alarm for Scale Down
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu-usage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.scale_down_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.scale_down_period
  statistic           = "Average"
  threshold           = var.scale_down_threshold
  alarm_description   = "Scale down when CPU usage drops below 3%"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}