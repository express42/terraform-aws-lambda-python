#!/usr/bin/env python
import json

def response(status=200, headers={'Content-Type': 'application/json'}, body=''):
    '''
    http://www.awslessons.com/2017/lambda-api-gateway-internal-server-error/
    '''
    if not body:
        return { 'statusCode': status }
    return {
        'statusCode': status,
        'headers': headers,
        'body': json.dumps(body)
    }

def lambda_handler(event, context):
    print(event)
    return response(status=200)


if __name__ == '__main__':
    pass