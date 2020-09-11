resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = var.ssh_key
}

resource "aws_iam_user" "name" {
  name = var.name
  force_destroy = "true"
}

output "user_arn" {
 value = aws_iam_user.name.arn
}


resource "aws_iam_user_ssh_key" "user" {
  username   = aws_iam_user.name.name
  encoding   = "SSH"
  public_key =  aws_key_pair.key_pair.public_key
#  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 mytest@mydomain.com"
}

resource "aws_iam_user_group_membership" "group1" {
  user = aws_iam_user.name.name

  groups = [
    aws_iam_group.group_name.name
  ]
}

#data "aws_iam_policy_document" "mi-global-role-for-all-policy-document" {
#  statement {
#    actions = ["sts:AssumeRole"]
#    sid     = "1"

#    principals {
#      type        = "Service"
#      identifiers = ["ec2.amazonaws.com"]
#    }
#  }
#}