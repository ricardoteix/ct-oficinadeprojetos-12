resource "aws_autoscaling_group" "autoscaling" {
  
  desired_capacity   = var.autoscaling-desejado
  max_size           = var.autoscaling-max
  min_size           = var.autoscaling-min

  vpc_zone_identifier = var.ec2-usar-ip-publico ? [
    aws_subnet.sn-projeto-public-1.id,
    aws_subnet.sn-projeto-public-2.id,
    aws_subnet.sn-projeto-public-3.id,
  ] : [
    aws_subnet.sn-projeto-private-1.id,
    aws_subnet.sn-projeto-private-2.id,
    aws_subnet.sn-projeto-private-3.id,
  ]

  target_group_arns = [
    aws_lb_target_group.tg-projeto.arn
  ]

  launch_template {
    id      = aws_launch_template.mediacms.id
    version = "$Latest"
  }
}

# ASG
# resource "aws_autoscaling_policy" "simple_scaling" {
#   name                   = "simple_scaling_policy"
#   scaling_adjustment     = 1
#   policy_type            = "SimpleScaling"
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 100
#   autoscaling_group_name = aws_autoscaling_group.autoscaling.name
# }

resource "aws_launch_template" "mediacms" {
  name = "${var.tag-base}"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = var.ec2-tamanho-ebs
    }
  }

  disable_api_stop        = false
  disable_api_termination = false

  ebs_optimized = false

  iam_instance_profile {
    name = aws_iam_instance_profile.projeto-profile.name
  }

  image_id = var.ec2-ami

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = var.ec2-tipo-instancia

  monitoring {
    enabled = false
  }

  # network_interfaces {
  #   associate_public_ip_address = false
  # }

  vpc_security_group_ids = [
    aws_security_group.sg_projeto_web.id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.tag-base}-mediacms"
    }
  }

  user_data = base64encode(data.template_file.projeto-user-data-script.rendered)  
}

# resource "aws_appautoscaling_target" "autoscaling_target" {
#   max_capacity       = var.autoscaling-max
#   min_capacity       = var.autoscaling-min
#   resource_id        = aws_autoscaling_group.autoscaling.id
#   scalable_dimension = "ec2:spot-fleet-request:TargetCapacity"
#   service_namespace  = "ec2"
# }

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "cpu-utilization-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "Scale-up when CPU utilization is greater than 70%"
  alarm_actions       = [aws_autoscaling_policy.scale_up_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling.name
  }
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "60"
  autoscaling_group_name = aws_autoscaling_group.autoscaling.name
}

resource "aws_cloudwatch_metric_alarm" "scale_down_cpu_alarm" {
  alarm_name          = "cpu-utilization-scale-down-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"
  alarm_description   = "Scale-down when CPU utilization is less than 40% for 2 consecutive periods."
  alarm_actions       = [aws_autoscaling_policy.scale_down_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling.name
  }
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "60"
  autoscaling_group_name = aws_autoscaling_group.autoscaling.name
}
