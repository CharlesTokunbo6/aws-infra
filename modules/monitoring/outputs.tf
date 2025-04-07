output "logs_bucket_id" {
  description = "ID of the logs S3 bucket"
  value       = aws_s3_bucket.logs.id
}

output "logs_bucket_arn" {
  description = "ARN of the logs S3 bucket"
  value       = aws_s3_bucket.logs.arn
}

output "cloudwatch_agent_profile_arn" {
  description = "ARN of the CloudWatch agent instance profile"
  value       = aws_iam_instance_profile.cloudwatch_agent.arn
}

output "cloudwatch_agent_profile_name" {
  description = "Name of the CloudWatch agent instance profile"
  value       = aws_iam_instance_profile.cloudwatch_agent.name
}
