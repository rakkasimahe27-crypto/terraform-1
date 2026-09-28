resource "aws_s3_bucket" "name" {
    bucket = var.bucket_name
    
    tags = {
        Name        = var.bucket_name
        Environment = var.environment
    }
  
}

resource "aws_s3_bucket_ownership_controls" "name" {
    bucket = aws_s3_bucket.name.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "name" {
    depends_on = [aws_s3_bucket_ownership_controls.name]
    bucket     = aws_s3_bucket.name.id
    acl        = var.bucket_acl
}

resource "aws_s3_bucket_versioning" "name" {
    bucket = aws_s3_bucket.name.id
    versioning_configuration {
        status = var.versioning_status
    }
}
