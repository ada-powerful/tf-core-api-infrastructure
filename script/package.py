#!/usr/bin/python3
import subprocess
import shutil
import pathlib
import logging
import boto3
from botocore.exceptions import ClientError
import os
import sys


def upload_file(file_name, bucket, object_name=None):
    """Upload a file to an S3 bucket

    :param file_name: File to upload
    :param bucket: Bucket to upload to
    :param object_name: S3 object name. If not specified then file_name is used
    :return: True if file was uploaded, else False
    """

    # If S3 object_name was not specified, use file_name
    if object_name is None:
        object_name = os.path.basename(file_name)

    # Upload the file
    s3_client = boto3.client('s3')
    try:
        response = s3_client.upload_file(file_name, bucket, object_name)
    except ClientError as e:
        logging.error(e)
        return False
    return True

def upload_artifact(bucket, api_version, repo_name, artifact_name):
    bashCommand = "git clone git@github.com:ada-powerful/{}.git".format(repo_name)
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    shutil.make_archive(artifact_name, 'zip', './{}'.format(repo_name))
    s3 = boto3.client('s3')
    with open("./{}.zip".format(artifact_name), "rb") as f:
        s3.upload_fileobj(f, bucket, "{}/{}.zip".format(api_version, artifact_name))
    shutil.rmtree('./{}/'.format(repo_name))
    pathlib.Path("./{}.zip".format(artifact_name)).unlink()

def update_lambda_funcs(funcs, bucket, s3_key):
    for func in funcs:
        update_lambda_func(func, bucket, s3_key)

def update_lambda_func(func_name, bucket, s3_key):
    client = boto3.client('lambda')
    repsonse = client.update_function_code(
        FunctionName=func_name,
        S3Bucket=bucket,
        S3Key=s3_key)
    logging.info(repsonse)

if __name__ == '__main__':
    bucket = sys.argv[1]
    api_version = sys.argv[2]

    upload_artifact(bucket, api_version, 'SiteCoreAPI', 'core')
    funcs = ['Channels', 'Categories', 'Articles', 'Topics', 'Operators', 'Prompts']
    update_lambda_funcs(funcs, bucket, "{}/{}.zip".format(api_version, 'core'))
    
    upload_artifact(bucket, api_version, 'py-aigc-packager', 'packager')
    funcs = ['Packager']
    update_lambda_funcs(funcs, bucket, "{}/{}.zip".format(api_version, 'packager'))
    
    upload_artifact(bucket, api_version, 'py-aigc-consumer', 'consumer')
    funcs = ['Consumer']
    update_lambda_funcs(funcs, bucket, "{}/{}.zip".format(api_version, 'consumer'))

