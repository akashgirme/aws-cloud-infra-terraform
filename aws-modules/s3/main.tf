resource "aws_s3_bucket" "s3_buckets" {
  count  = length(var.bucket_names)
  bucket = var.bucket_names[count.index]

  // Set force_destroy to false in production
  force_destroy = true # Setting this to true allows Terraform to destroy non-empty buckets
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  count  = length(aws_s3_bucket.s3_buckets)
  bucket = aws_s3_bucket.s3_buckets[count.index].id

  versioning_configuration {
    status = "Enabled"
  }
}



// This Buckest are always require and Don't Ever Delete them
// Always keep force_destroy set to false
// Bucket for Build Artifacts

# resource "aws_s3_bucket" "build_artifact_bucket" {
#   bucket = var.build_artifact_bucket

#   // Set force_destroy to false in production
#   force_destroy = false # Setting this to true allows Terraform to destroy non-empty buckets
# }

# resource "aws_s3_bucket_versioning" "build_artifact_bucket_versioning" {
#   bucket = aws_s3_bucket.build_artifact_bucket.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }


# resource "aws_s3_bucket" "lb_connection_logs_bucket" {
#   bucket = var.lb_connection_logs_bucket

#   // Set force_destroy to false in production
#   force_destroy = false # Setting this to true allows Terraform to destroy non-empty buckets
# }


# resource "aws_s3_bucket_versioning" "lb_connection_logs_bucket_versioning" {
#   bucket = aws_s3_bucket.lb_connection_logs_bucket.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket" "production_database_dumps_bucket" {
#   bucket = var.production_database_dumps_bucket

#   // Set force_destroy to false in production
#   force_destroy = false # Setting this to true allows Terraform to destroy non-empty buckets
# }


# resource "aws_s3_bucket_versioning" "production_database_dumps_bucket" {
#   bucket = aws_s3_bucket.production_database_dumps_bucket.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }
