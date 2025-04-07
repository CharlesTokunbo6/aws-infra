output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_lock.id
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_lock.arn
}