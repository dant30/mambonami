from django.conf import settings
from django.core.files.storage import FileSystemStorage, Storage
from django.utils.deconstruct import deconstructible
from storages.backends.s3boto3 import S3Boto3Storage


class SpacesPublicMediaStorage(S3Boto3Storage):
    bucket_name = settings.DO_SPACES_PUBLIC_BUCKET
    region_name = settings.DO_SPACES_REGION
    endpoint_url = settings.DO_SPACES_ENDPOINT
    access_key = settings.DO_SPACES_PUBLIC_ACCESS_KEY
    secret_key = settings.DO_SPACES_PUBLIC_SECRET_KEY
    custom_domain = settings.DO_SPACES_CDN_DOMAIN or None
    url_protocol = 'https:'
    default_acl = 'public-read'
    querystring_auth = False
    file_overwrite = False
    location = 'media'
    object_parameters = {'CacheControl': 'public, max-age=31536000, immutable'}


class SpacesPrivateMediaStorage(S3Boto3Storage):
    bucket_name = settings.DO_SPACES_PRIVATE_BUCKET
    region_name = settings.DO_SPACES_REGION
    endpoint_url = settings.DO_SPACES_ENDPOINT
    access_key = settings.DO_SPACES_PRIVATE_ACCESS_KEY
    secret_key = settings.DO_SPACES_PRIVATE_SECRET_KEY
    custom_domain = None
    url_protocol = 'https:'
    default_acl = 'private'
    querystring_auth = True
    querystring_expire = 300
    file_overwrite = False
    location = 'private'
    object_parameters = {'CacheControl': 'private, no-store'}


@deconstructible
class PrivateMediaStorage(Storage):
    """Use local disk in development and the private Space in production."""

    def __init__(self):
        if settings.USE_S3:
            self.backend = SpacesPrivateMediaStorage()
        else:
            self.backend = FileSystemStorage(
                location=settings.MEDIA_ROOT,
                base_url=settings.MEDIA_URL,
            )

    def _open(self, name, mode='rb'):
        return self.backend.open(name, mode)

    def _save(self, name, content):
        return self.backend.save(name, content)

    def delete(self, name):
        return self.backend.delete(name)

    def exists(self, name):
        return self.backend.exists(name)

    def listdir(self, path):
        return self.backend.listdir(path)

    def size(self, name):
        return self.backend.size(name)

    def url(self, name):
        return self.backend.url(name)

    def path(self, name):
        return self.backend.path(name)
