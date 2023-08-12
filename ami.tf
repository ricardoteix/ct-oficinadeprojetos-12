# resource "aws_ami_from_instance" "mediacms-ami" {
#   count = var.use-upload-instance == 1 ? 1 : 0
#   name                = "mediacms-ami"
#   source_instance_id = aws_instance.upload[0].id
  
#   tags = {
#       Name = "${var.tag-base}-mediacms-ami"
#   }
# }