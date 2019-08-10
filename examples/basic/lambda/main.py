#!/usr/bin/env python
'''
Echo service as a Lambda function
'''

import os
import sys
import json
import logging
from pprint import pformat

# Hack to use dependencies from lib directory
BASE_PATH = os.path.dirname(__file__)
sys.path.append(BASE_PATH + "/lib")

LOGGER = logging.getLogger(__name__)
logging.getLogger().setLevel(logging.INFO)

def response(status=200, headers=None, body=''):
    '''
    http://www.awslessons.com/2017/lambda-api-gateway-internal-server-error/
    '''
    if not body:
        return {'statusCode': status}

    if headers is None:
        headers = {'Content-Type': 'application/json'}

    return {
        'statusCode': status,
        'headers': headers,
        'body': json.dumps(body)
    }

def lambda_handler(event, context):
    '''
    This function is called on HTTP request.
    It logs the request and an execution context. Then it returns body of the request.
    '''
    LOGGER.info("%s", pformat({"Context" : vars(context), "Request": event}))
    return response(status=200, body=event['body'])


if __name__ == '__main__':
    # Do nothing if executed as a script
    pass
