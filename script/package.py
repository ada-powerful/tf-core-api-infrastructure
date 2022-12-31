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

if __name__ == '__main__':
    bucket = sys.argv[1]
    api_version = sys.argv[2]
    bashCommand = "git clone git@github.com:ada-powerful/SiteCoreAPI.git"
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    shutil.make_archive('core', 'zip', './SiteCoreAPI')
    s3 = boto3.client('s3')
    with open("./core.zip", "rb") as f:
        s3.upload_fileobj(f, bucket, "{}/core.zip".format(api_version))
    shutil.rmtree('./SiteCoreAPI/')
    pathlib.Path("./core.zip").unlink()

