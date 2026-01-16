
resource "aws_instance" "recipe_slave" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.slave_instance_type
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.recipe_slave.id]
  key_name               = var.mykey

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}
