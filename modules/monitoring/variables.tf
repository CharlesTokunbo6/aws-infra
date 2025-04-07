variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
  default     = ""
}
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket for logs"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail logging"
  type        = bool
  default     = true
}
