resource "aws_s3_bucket" "my-s3-bucket" {
  bucket = "12380123-guzmax-s3-bucket"

  lifecycle_rule {
    id = "move_images_to_glacier_after_90_days"
    prefix = "images/"
    transition {
      storage_class = "GLACIER"
      days = 90
    }
    enabled = true
  }

  lifecycle_rule {
    id = "expire_logs_after_30_days"
    prefix = "logs/"
    expiration {
      days = 90
    }
    enabled = true
  }
}

resource "aws_s3_bucket_acl" "s3-acl" {
  bucket = aws_s3_bucket.my-s3-bucket.id
  acl    = "private"
}
