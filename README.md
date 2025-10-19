## Project Overview
This project implements a **Payment Gateway** system on AWS using services like **SQS, SNS, Lambda, and DynamoDB**. It is designed to handle payment requests asynchronously and provide notifications for payment status.

---

## Features
- **AWS SQS**: Queue for processing payment requests asynchronously.
- **AWS SNS**: Notification service for payment updates.
- **AWS Lambda**: Serverless functions to process payments and trigger notifications.
- **Terraform Infrastructure**: Infrastructure as code for deploying AWS resources.
- **Secure Handling**: Sensitive information handled via environment variables or `.tfvars` files.

---

## Architecture
```

User --> Payment Request --> SQS Queue --> Lambda Processor --> Payment Gateway API
|
v
SNS Notification --> User

````

---

## Prerequisites
- AWS account with appropriate permissions
- Terraform installed (v1.0+ recommended)
- AWS CLI configured
- Python 3.8+ (if Lambda functions are in Python)
- Git

---

## Setup Instructions

### Clone the Repository
```bash
git clone https://github.com/Vinitha-Arun-max/awspaymentgatewayproject.git
cd awspaymentgatewayproject
````

### Configure Terraform

```bash
# Initialize Terraform
terraform init

# Plan the infrastructure
terraform plan

# Apply the infrastructure
terraform apply
```

### Deploy Lambda Functions

* Package your Lambda functions (if using Python):

```bash
zip payment_processor.zip payment_processor.py
```

* Upload via Terraform or AWS Console.

---

## Usage

1. Send a payment request to the SQS queue.
2. Lambda processes the request.
3. SNS sends notification about payment status.
4. Monitor logs via CloudWatch.

---

## Project Structure

```
awspaymentgatewayproject/
├── lambda/                 # Lambda function code
├── terraform/              # Terraform scripts
├── README.md
├── .gitignore
└── scripts/                # Helper scripts (optional)
```

---

## Security Considerations

* Do **not** commit `.tfstate` or `.tfvars` files.
* Use IAM roles with least privilege for Lambda and SQS/SNS access.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Author

**Vinitha Arun**
