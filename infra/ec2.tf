# ------------------------------
# EC2 Instance Configuratioh
# ------------------------------
resource "aws_instance" "app_server" {
  ami           = "ami-0bba69335379e17f8"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
