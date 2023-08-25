# ------------------------------
# IAM Configuration
# ------------------------------
# ECS
resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${local.prefix}-task-exec-role-policy"
  path        = "/"
  description = "Allow retrieving of images and adding to logs"
  policy      = file("./templates/ecs/task-exec-role.json")
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${local.prefix}-task-exec-role"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}

resource "aws_iam_role" "app_iam_role" {
  name               = "${local.prefix}-api-task"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

# Bastion
# 踏み台サーバ用のIAMロールを作成
resource "aws_iam_role" "bastion" {
  name = "${local.prefix}-bastion"
  # sts:AssumeRole(別のIAMロールへの切り替えを許可)を割り当てる
  assume_role_policy = file("./templates/bastion/instance-profile-policy.json")

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-bastion-role" })
  )
}

resource "aws_iam_policy" "bastion_access_role_policy" {
  name        = "${local.prefix}-bastion_access_role_policy"
  path        = "/"
  description = "Allow bastion instance to access ec2 instances using session manager"
  policy      = file("./templates/bastion/bastion-access-role.json")
}

# IAMロールにポリシーを割り当てる
resource "aws_iam_role_policy_attachment" "bastion_attach_policy" {
  role       = aws_iam_role.bastion.name
  # セッションマネージャーを使って接続できるよう設定
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAMインスタンスプロファイルを設定(IAMロールに相当するもの)
# インスタンスプロファイルにロールを割り当てる
resource "aws_iam_instance_profile" "bastion" {
  name = "${local.prefix}-bastion-instance-profile"
  role = aws_iam_role.bastion.name
}