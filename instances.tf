resource "aws_instance" "redhat-sub1" {
  # Instance to ssh into (based on instruction 1)
  # Red Hat Enterprise Linux 8 (HVM), SSD Volume Type ami
  ami                    = "ami-0b0af3577fe5e3532"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Sub1-us-east-1a.id
  key_name = "aws_key"
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "redhat instance sub1"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDU4whWtS8fN16U1IFYJOPLua0CZnVD88vfTC/jnfe0622BN65E/9kiGjo+STULvV06RVcVZ/emgahfppUBQhQQqxq3MbHpiRcrxhpD8LBA31sm7o+i23elpNWm+byDiYHMj+S8Z4w9zDc1yCNqgIFPOLj1pE+kNCJiqHFdaL8zo+EosjSALGJRhzl3vqHRCHy8FLsz0sCOqR2gBo2sObyWfnObTjMfOP89pzeOvmi+sNoSMyUyjzYK5R5qcCvSIm3ehc8IvmAFHxsA2miL100hj56+uK4HGRkvCzx1kRCh7asHNlpn/EsB0EgPUUKgjmONZmJqOfcEq9Ec4KSRAAyj xavier@XavierPC"
}

resource "aws_instance" "redhat-sub2-us-east-1b" {
  # Red Hat Enterprise Linux 8 (HVM), SSD Volume Type ami
  ami           = "ami-0b0af3577fe5e3532"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Sub2-us-east-1b.id
  tags = {
    Name = "redhat instance sub2"
  }
}

resource "aws_ebs_volume" "redhat-sub2-us-east-1b-ebs-volume" {
  availability_zone = "us-east-1b"
  size              = 20
}

resource "aws_volume_attachment" "attach-redhat-sub2-us-east-1b-ebs-volume" {
  device_name = "/dev/sdh"
  instance_id = aws_instance.redhat-sub2-us-east-1b.id
  volume_id   = aws_ebs_volume.redhat-sub2-us-east-1b-ebs-volume.id
}

resource "aws_launch_configuration" "redhat-sub4-asg-launch-configuration" {
  image_id      = "ami-0b0af3577fe5e3532" # Red Hat Enterprise Linux 8 (HVM), SSD Volume Type ami
  instance_type = "t2.micro"
  ebs_block_device {
    device_name = "/dev/sdh"
    volume_type = "gp2"
    volume_size = 20
  }
  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF
}

resource "aws_placement_group" "redhat-asg-placement-group" {
  name     = "redhat-asg-placement-group"
  strategy = "partition"
}

resource "aws_autoscaling_group" "redhat-asg-autoscaling-group" {
  max_size                  = 6
  min_size                  = 2
  launch_configuration      = aws_launch_configuration.redhat-sub4-asg-launch-configuration.name
  placement_group           = aws_placement_group.redhat-asg-placement-group.id
  health_check_grace_period = 300
  vpc_zone_identifier       = [aws_subnet.Sub4-us-east-1a.id]
}

resource "aws_lb" "sub4-lb" {
  name                             = "sub-4-lb"
  load_balancer_type               = "application"
  subnets                          = [aws_subnet.Sub4-us-east-1a.id, aws_subnet.Sub4-us-east-1b.id]
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "sub4-lb-listener" {
  load_balancer_arn = aws_lb.sub4-lb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sub4-lb-target-group.arn
  }
  port     = "80"
  protocol = "HTTP"
}

resource "aws_lb_target_group" "sub4-lb-target-group" {
  vpc_id = aws_vpc.poc-vpc.id
  depends_on = [
    aws_lb.sub4-lb
  ]
  port     = 80
  protocol = "HTTP"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "sub4-lb-target" {
  autoscaling_group_name = aws_autoscaling_group.redhat-asg-autoscaling-group.id
  alb_target_group_arn    = aws_lb_target_group.sub4-lb-target-group.arn
}