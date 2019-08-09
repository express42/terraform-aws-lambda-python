#!/usr/bin/env python
# Hack to use dependencies from lib directory
import sys
import os
base_path = os.path.dirname(__file__)
sys.path.append(base_path + "/lib")

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
    return response(status=200, body=event['body'])


if __name__ == '__main__':
    pass
