# Criando EFS
resource "aws_efs_file_system" "projeto-efs" {
  creation_token = "${var.tag-base}-efs" # Usado posteriormente com AWS CLI para montar o EFS
  tags = {
     Name = "${var.tag-base}"
   }
 }

resource "aws_efs_mount_target" "projeto-efs-mt" {
   file_system_id  = aws_efs_file_system.projeto-efs.id
   subnet_id = aws_subnet.sn-projeto-public-1.id
   security_groups = [aws_security_group.sg_projeto_efs.id]
 }