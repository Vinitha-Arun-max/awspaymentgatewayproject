import json

def lambda_handler (event.context):
    for record in event ['Records'] :
        message = json.load (record['body'])
        print ("processing payment",message)
    return {"status": "processed"}

