# secret variables, should also only be entered in `terraform.tfvars` file
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "region" {
    description = "AWS Region"
    type = string
    default = "us-east-1"
}