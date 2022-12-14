locals {
  ip_set = [for i in var.allow_cidr : split("/", i)[0]]
  ip_map = {
    for i in toset(jsondecode(data.http.ip.response_body)) : i.query => "${replace(lower(i.as), "/ |,|-/", "_")}_${lower(i.city)}_${lower(i.countryCode)}"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "http" "ip" {
  url          = "http://ip-api.com/batch?fields=query,as,city,countryCode"
  method       = "POST"
  request_body = jsonencode(local.ip_set)
}

resource "aws_security_group" "this" {
  name        = "demo_security_group"
  description = "Demo security group with annotated rules"
  vpc_id      = var.vpc_id
  tags = {
    Name = "demo_security_group"
  }
}

resource "aws_security_group_rule" "https_ingress" {
  for_each          = toset(var.allow_cidr)
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${each.key}"]
  description       = lookup(local.ip_map, split("/", each.key)[0], "tf")
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "tf managed - allow all egress"
  security_group_id = aws_security_group.this.id
}
