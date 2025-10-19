output "sns_topic" {
  value = aws_sns_topic.payment_events.arn
}
output "sqs_queue" {
  value = aws_sqs_queue.payment_queue.id
}
