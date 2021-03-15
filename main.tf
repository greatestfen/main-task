terraform {
  required_version = ">= 0.11.0"
}

provider "aws" {
  region = "eu-central-1"
  shared_credentials_file = "/Users/macpro/.aws/credentials"
  profile = "default"
}

resource "aws_instance" "ubuntu" {
  count         = "2"
  ami           = "ami-0767046d1677be5a0"
  instance_type = "t2.micro"
  key_name      = "t2micro"
  vpc_security_group_ids = [
       "sg-d67899a8",
    ]
  tags          = {
    Name        = "${element(var.instance_tags, count.index)}"
  }
}