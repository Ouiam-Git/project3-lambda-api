import json


def lambda_handler(event, context):
    name = "World"

    if event.get("queryStringParameters") and event["queryStringParameters"].get("name"):
        name = event["queryStringParameters"]["name"]

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": f"Hello, {name}!"}),
    }
