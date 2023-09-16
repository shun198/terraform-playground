# ------------------------------
# IAM Configuration
# ------------------------------
# ECS
resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${local.prefix}-task-exec-role-policy"
  path        = "/"
  description = "Allow retrieving images and adding to logs"
  policy      = file("./templates/ecs/task-exec-role.json")
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${local.prefix}-task-exec-role"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-task-execution-role" })
  )
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

resource "aws_iam_role" "task_role" {
  name               = "${local.prefix}-task-role"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}

# Bastion
# 踏み台サーバ用のIAMロールを作成
# resource "aws_iam_role" "bastion" {
#   name = "${local.prefix}-bastion"
#   # sts:AssumeRole(別のIAMロールへの切り替えを許可)を割り当てる
#   assume_role_policy = file("./templates/bastion/instance-profile-policy.json")

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}-bastion-role" })
#   )
# }

# # IAMロールにポリシーを割り当てる
# resource "aws_iam_role_policy_attachment" "bastion_attach_policy" {
#   role = aws_iam_role.bastion.name
#   # EC2インスタンスへセッションマネージャーを使って接続するポリシー(AmazonSSMManagedInstanceCore)をアタッチする
#   # https://docs.aws.amazon.com/ja_jp/aws-managed-policy/latest/reference/AmazonSSMManagedInstanceCore.html
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# # IAMインスタンスプロファイルを設定(IAMロールに相当するもの)
# # インスタンスプロファイルにロールを割り当てる
# resource "aws_iam_instance_profile" "bastion" {
#   name = "${local.prefix}-bastion-instance-profile"
#   role = aws_iam_role.bastion.name
# }
