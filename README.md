# aws-security-groups

Annotate security group rules using a public api providing geo-location info

## Problem

Automate adding geolocation, and organization info to security group rules, to better identify the usecase. Depending on operators or PR reviews to ensure this info is put in for every change often causes delays.

Although this automation is only as good as the underlying data being use, it is still better than expecting someone to gather this information manually.

## Source - Geolocation info

The source of geo-location data is a public API - http://ip-api.com/

We use the batch api with a couple of parameters to reduce the json payload received.

## Run

Initialize the terraform configs, and create a plan using - 

```
terraform init
terraform plan -var-file development.tfvars
```

Inspect the plan to validate rule's description, which should now contain the organization name, and geo location info. In this example, since we are using Google IPs, so it populates the description accordingly. Quoting the relevant bits here.

```
..
description = "as15169_google_llc_ashburn_us"
..

```

Full terraform plan would look like this - 

```
Terraform will perform the following actions:

  # aws_security_group.this will be created
  + resource "aws_security_group" "this" {
      + arn                    = (known after apply)
      + description            = "Demo security group with annotated rules"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "demo_security_group"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "demo_security_group"
        }
      + tags_all               = {
          + "Name" = "demo_security_group"
        }
      + vpc_id                 = "vpc-<redacted>"
    }

  # aws_security_group_rule.egress will be created
  + resource "aws_security_group_rule" "egress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + description              = "tf managed - allow all egress"
      + from_port                = 0
      + id                       = (known after apply)
      + protocol                 = "-1"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 0
      + type                     = "egress"
    }

  # aws_security_group_rule.https_ingress["8.8.4.4/32"] will be created
  + resource "aws_security_group_rule" "https_ingress" {
      + cidr_blocks              = [
          + "8.8.4.4/32",
        ]
      + description              = "as15169_google_llc_ashburn_us"
      + from_port                = 443
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 443
      + type                     = "ingress"
    }

  # aws_security_group_rule.https_ingress["8.8.8.8/32"] will be created
  + resource "aws_security_group_rule" "https_ingress" {
      + cidr_blocks              = [
          + "8.8.8.8/32",
        ]
      + description              = "as15169_google_llc_ashburn_us"
      + from_port                = 443
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 443
      + type                     = "ingress"
    }

Plan: 4 to add, 0 to change, 0 to destroy.
```

## Considerations

Please be aware of the rate limits of the public api https://ip-api.com, as well as their terms of service.
