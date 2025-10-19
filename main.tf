#Create SNS topics for payment events:
resource "aws_sns_topic" "payment_events" {
  name = "payment-events"
}

#Create SQS queue for processing payments:
resource "aws_sqs_queue" "payment_queue" {
  name = "payment-processing-queue"
}

#Allow SNS to send message to SQS:
resource "aws_sqs_queue_policy" "payment_queue_policy" {
  queue_url = aws_sqs_queue.payment_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowFromSNS"
        Effect    = "Allow"
        Principal = {
          AWS = "*"
         }
        Action    = "SQS:SendMessage"
        Resource  = aws_sqs_queue.payment_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.payment_events.arn
          }
        }
      }
    ]
  })
}

#subscribe SQS to SNS

resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn = aws_sns_topic.payment_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.payment_queue.arn
}

#create lambda role policy
resource "aws_iam_role" "lambda_role" {
  name = "lambda_payment_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#Add SNS+SQS permission

resource "aws_iam_policy" "lambda_sns_sqs_policy" {
  name = "lambda-sns-sqs-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sns:publish", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_sns_sqs_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sns_sqs_policy.arn
}

#Lambda:payment service( publishes SNS)
resource "aws_lambda_function" "payment_service" {
  filename      = "lambda/payment-service.zip"
  function_name = "payment_service"
  role          = aws_iam_role.lambda_role.arn
  handler       = "payment_service.lambda_handler"
  runtime       = "python3.9"
  environment {
    variables = {
      SNS_Topic_ARN = aws_sns_topic.payment_events.arn
    }
  }
}

#Lambda: Payment processor:
resource "aws_lambda_function" "payment_processor" {
  filename      = "lambda/payment_processor.zip"
  function_name = "payment_processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "payment_processor.lambda_handler"
  runtime       = "python3.9"
  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.payment_queue.id
    }
  }
}

# Triger payment processor Lambda from SQS:
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.payment_queue.arn
  function_name    = aws_lambda_function.payment_processor.arn
  batch_size       = 5
}

#outputs

output "sns_topic_arn" {
  value = aws_sns_topic.payment_events.arn
}
output "sqs_queue_url" {
  value = aws_sqs_queue.payment_queue.id
}
