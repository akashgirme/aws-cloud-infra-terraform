variable "bucket_names" {
  description = "List of S3 bucket names"
  type        = list(string)
  #Bucket name is global on overall aws, Choose unique bucket name
}

# variable "build_artifact_bucket" {
#   type    = string
#   default = "skillstreet-application-build-artifacts"

# }

# variable "terraform_state_file_bucket" {
#   type    = string
#   default = "skillstreet-terrform-statefile-store"

# }

# variable "lb_connection_logs_bucket" {
#   type    = string
#   default = "skillstreet-load-balancer-logs"
# }

# variable "production_database_dumps_bucket" {
#   type    = string
#   default = "skillstreet-production-database-dumps-bucket"
# }