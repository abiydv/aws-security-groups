variable "allow_cidr" {
  type        = list(string)
  description = "List of cidr ranges to add to the security group."
}

variable "vpc_id" {
  type        = string
  description = "Create security group in this vpc id."
}
