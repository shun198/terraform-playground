# ------------------------------
# EC2 Instance Configuratioh
# ------------------------------
resource "aws_instance" "app_server" {
  ami           = "ami-0bba69335379e17f8"
  instance_type = "t2.micro"

  # mergeを使ってtagをoverrideする
  tags = merge(
    # common_tagとnameを合体させてつける
    local.common_tags,
    map("Name","${local.prefix}-ExampleAppServerInstance")
  )
}
