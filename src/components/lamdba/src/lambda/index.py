import json

def handler(event, context):
    """
    This is the main handler function for the AWS Lambda.
    It takes an 'event' (the input to the Lambda) and a 'context' object.
    """
    print(f"Received event: {json.dumps(event)}")

    # Example: Check if a 'name' is provided in the event body
    name = "World"
    if event and 'body' in event:
        try:
            body = json.loads(event['body'])
            if 'name' in body:
                name = body['name']
        except json.JSONDecodeError:
            pass # Ignore if body is not valid JSON

    response_message = f"Hello, {name} from a Nuon-deployed Lambda!"

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({'message': response_message})
    }

