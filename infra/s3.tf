# ------------------------------
# S3 Bucket Configuration
# ------------------------------
resource "aws_s3_bucket" "app_public_files" {
  # バケット名を指定
  bucket = "${local.prefix}-files"
  # 今回は検証用のため、focre_destroy=trueにする
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.app_public_files.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# インターネット上からアクセスできるようにする
resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.app_public_files.id
  acl    = "private"
}