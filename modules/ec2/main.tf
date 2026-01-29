resource "aws_security_group" "ec2" {
  name        = "${var.environment}-ec2-sg"
  description = "EC2 security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-ec2-sg"
  }
}


resource "aws_iam_role" "ec2" {
  name = "${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}



resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ec2" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name
}


resource "aws_launch_template" "this" {
  name_prefix   = "${var.environment}-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  network_interfaces {
    security_groups = [aws_security_group.ec2.id]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello from ${var.environment}" > /var/www/html/index.html
EOF
  )
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}


resource "aws_autoscaling_group" "this" {
  name                = "${var.environment}-asg"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-ec2"
    propagate_at_launch = true
  }
}
