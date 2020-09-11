resource "aws_iam_group" "group_name" {
  name = var.web_group_name
}

resource "aws_iam_policy_attachment" "ReadOnly-attach" {
  name       = "ReadOnly-Attachment"
#  users      = [aws_iam_user.user.name]
#  roles      = [aws_iam_role.role.name]
  groups     = [aws_iam_group.group_name.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
