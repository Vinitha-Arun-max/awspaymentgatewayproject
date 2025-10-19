import boto3
import os
import json

sns = boto3.client (sns)
topic_arn = os.environ ['SNS_TOPIC_ARN']
def lambda_handler (event,context):
    payment_event = {
     "order_id" : "ORD12345"
     "amount" : 150.00,
     "status" : "INITIATED"
}
sns.publish (
        TopicArn = topic_arn,
        Message = json.dumps (payment_event),
        Subject = "New Payment Event"
       )
return { "statuscode":200, "body" : "payment event published to SNS" }

