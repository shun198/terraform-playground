# ------------------------------
# S3 Bucket Configuration
# ------------------------------
resource "aws_s3_bucket" "app_public_files" {
  bucket = "${local.prefix}-files"
  # インターネット上からアクセスできるようにする
  acl = "public-read"
  # 今回は検証用のため、focre_destroy=trueにする
  force_destroy = true
}
