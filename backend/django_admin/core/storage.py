# core/storage.py
from django.core.files.storage import Storage
from django.conf import settings
import boto3
from botocore.exceptions import ClientError
import os

class S3MediaStorage(Storage):
    """
    Custom S3 storage for media files.
    Falls back to local filesystem if S3 is not configured.
    """
    def __init__(self):
        if settings.USE_S3:
            self.s3_client = boto3.client(
                's3',
                aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
                aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
                region_name=settings.AWS_S3_REGION_NAME
            )
            self.bucket = settings.AWS_STORAGE_BUCKET_NAME
        else:
            self.s3_client = None
    
    def _open(self, name, mode='rb'):
        if self.s3_client:
            response = self.s3_client.get_object(Bucket=self.bucket, Key=name)
            return response['Body']
        else:
            return open(os.path.join(settings.MEDIA_ROOT, name), mode)
    
    def _save(self, name, content):
        if self.s3_client:
            self.s3_client.upload_fileobj(content, self.bucket, name)
        else:
            path = os.path.join(settings.MEDIA_ROOT, name)
            with open(path, 'wb') as f:
                for chunk in content.chunks():
                    f.write(chunk)
        return name
    
    def delete(self, name):
        if self.s3_client:
            self.s3_client.delete_object(Bucket=self.bucket, Key=name)
        else:
            os.remove(os.path.join(settings.MEDIA_ROOT, name))
    
    def exists(self, name):
        if self.s3_client:
            try:
                self.s3_client.head_object(Bucket=self.bucket, Key=name)
                return True
            except ClientError:
                return False
        else:
            return os.path.exists(os.path.join(settings.MEDIA_ROOT, name))
    
    def url(self, name):
        if self.s3_client:
            return f"https://{self.bucket}.s3.amazonaws.com/{name}"
        return settings.MEDIA_URL + name