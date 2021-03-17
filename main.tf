terraform {
  required_version = ">= 0.11.0"
}

provider "aws" {
  region = "eu-central-1"
  shared_credentials_file = "/Users/macpro/.aws/credentials"
  profile = "default"
}

resource "aws_instance" "build" {
  count         = "1"
  ami           = "ami-0767046d1677be5a0"
  instance_type = "t2.micro"
  key_name      = "t2micro"
  security_groups = [
       "sg-0e3ed7259ec3533d1",
    ]
  tags = { 
    Name = "Build"
  }
}

resource "aws_instance" "staging" {
  count         = "1"
  ami           = "ami-0767046d1677be5a0"
  instance_type = "t2.micro"
  key_name      = "t2micro"
  security_groups = [
       "sg-0e3ed7259ec3533d1",
    ]
  tags = {
    Name = "Staging"
  }
}