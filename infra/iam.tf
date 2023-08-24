# IAM 関連の設定
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

# IAMロールにポリシーを割り当てる
resource "aws_iam_role_policy_attachment" "bastion_attach_policy" {
  role = aws_iam_role.bastion.name
  # EC2に対するRead Only権限を付与
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EC2を作成する画面にIAMロールをアタッチする箇所がなく、
# IAMインスタンスプロファイルを設定する箇所が存在するため(IAMロールに相当するもの)
# aws_iam_instance_profileを使ってIAMロールをEC2インスタンスにアタッチする
resource "aws_iam_instance_profile" "bastion" {
  name = "${local.prefix}-bastion-instance-profile"
  role = aws_iam_role.bastion.name
}