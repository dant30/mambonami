from tempfile import TemporaryDirectory

from django.core.files.base import ContentFile
from django.test import SimpleTestCase, override_settings

from core.storage_backends import (
    PrivateMediaStorage,
    SpacesPrivateMediaStorage,
    SpacesPublicMediaStorage,
    _normalize_cdn_domain,
)


class SpacesStoragePolicyTests(SimpleTestCase):
    def test_cdn_domain_accepts_url_or_hostname(self):
        self.assertEqual(
            _normalize_cdn_domain('https://cdn.example.com/media/'),
            'cdn.example.com',
        )
        self.assertEqual(
            _normalize_cdn_domain('cdn.example.com'),
            'cdn.example.com',
        )
        self.assertEqual(
            _normalize_cdn_domain('https//cdn.example.com'),
            'cdn.example.com',
        )

    def test_public_media_is_public_and_not_signed(self):
        self.assertEqual(SpacesPublicMediaStorage.default_acl, 'public-read')
        self.assertFalse(SpacesPublicMediaStorage.querystring_auth)

    def test_private_media_is_private_and_uses_short_lived_signed_urls(self):
        self.assertEqual(SpacesPrivateMediaStorage.default_acl, 'private')
        self.assertTrue(SpacesPrivateMediaStorage.querystring_auth)
        self.assertEqual(SpacesPrivateMediaStorage.querystring_expire, 300)

    def test_private_storage_uses_local_filesystem_in_development(self):
        with TemporaryDirectory() as media_root:
            with override_settings(USE_S3=False, MEDIA_ROOT=media_root, MEDIA_URL='/media/'):
                storage = PrivateMediaStorage()
                name = storage.save('verification/sample.txt', ContentFile(b'private document'))

                self.assertTrue(storage.exists(name))
                with storage.open(name, 'rb') as stored_file:
                    self.assertEqual(stored_file.read(), b'private document')
                self.assertEqual(storage.url(name), '/media/verification/sample.txt')
                storage.delete(name)
                self.assertFalse(storage.exists(name))
