import os
from pathlib import Path

import boto3
from django.apps import apps
from django.core.files import File
from django.core.management.base import BaseCommand, CommandError
from django.db.models import Q
from django.db.models.fields.files import FileField


class Command(BaseCommand):
    help = 'Copy existing Django FileField uploads into their configured Spaces storage.'

    def add_arguments(self, parser):
        parser.add_argument('--dry-run', action='store_true', help='List files without copying them.')

    def handle(self, *args, **options):
        source_backend = os.environ.get('MEDIA_MIGRATION_SOURCE_BACKEND', 'local').lower()
        if source_backend not in {'local', 's3'}:
            raise CommandError('MEDIA_MIGRATION_SOURCE_BACKEND must be local or s3.')

        configured_source_root = os.environ.get('MEDIA_MIGRATION_SOURCE_ROOT', '')
        source_root = Path(configured_source_root).resolve() if source_backend == 'local' and configured_source_root else None
        source_client = self._get_s3_source_client() if source_backend == 's3' else None
        source_bucket = os.environ.get('MEDIA_MIGRATION_SOURCE_BUCKET', '')
        if source_backend == 'local' and not source_root:
            raise CommandError('Set MEDIA_MIGRATION_SOURCE_ROOT to the existing media directory.')
        if source_backend == 's3' and not source_bucket:
            raise CommandError('Set MEDIA_MIGRATION_SOURCE_BUCKET for S3 source mode.')

        copied = 0
        skipped = 0
        failed = 0

        for model in apps.get_models():
            file_fields = [field for field in model._meta.get_fields() if isinstance(field, FileField)]
            for field in file_fields:
                queryset = model._default_manager.exclude(Q(**{f'{field.name}__isnull': True}) | Q(**{field.name: ''}))
                for record in queryset.iterator():
                    stored_name = getattr(record, field.name).name
                    if not stored_name:
                        continue
                    destination = field.storage
                    if destination.exists(stored_name):
                        skipped += 1
                        continue
                    if options['dry_run']:
                        self.stdout.write(f'Would copy {model._meta.label}.{field.name}: {stored_name}')
                        continue
                    try:
                        with self._open_source(source_backend, source_root, source_client, source_bucket, stored_name) as source_file:
                            destination.save(stored_name, source_file)
                        copied += 1
                        self.stdout.write(f'Copied {model._meta.label}.{field.name}: {stored_name}')
                    except Exception as exc:
                        failed += 1
                        self.stderr.write(self.style.ERROR(f'Failed {model._meta.label}.{field.name} {stored_name}: {exc}'))

        self.stdout.write(self.style.SUCCESS(f'Media copy finished: {copied} copied, {skipped} already present, {failed} failed.'))
        if failed:
            raise CommandError('Some media files could not be copied; review the errors and rerun after fixing the source.')

    @staticmethod
    def _get_s3_source_client():
        endpoint = os.environ.get('MEDIA_MIGRATION_SOURCE_ENDPOINT') or None
        region = os.environ.get('MEDIA_MIGRATION_SOURCE_REGION') or None
        access_key = os.environ.get('MEDIA_MIGRATION_SOURCE_ACCESS_KEY')
        secret_key = os.environ.get('MEDIA_MIGRATION_SOURCE_SECRET_KEY')
        if not access_key or not secret_key:
            raise CommandError('S3 source mode requires MEDIA_MIGRATION_SOURCE_ACCESS_KEY and MEDIA_MIGRATION_SOURCE_SECRET_KEY.')
        return boto3.client(
            's3',
            endpoint_url=endpoint,
            region_name=region,
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key,
        )

    @staticmethod
    def _open_source(source_backend, source_root, source_client, source_bucket, name):
        if source_backend == 's3':
            response = source_client.get_object(Bucket=source_bucket, Key=name)
            return File(response['Body'], name=name)

        source_path = (source_root / name).resolve()
        if source_root not in source_path.parents and source_path != source_root:
            raise CommandError(f'Unsafe media path in database: {name}')
        if not source_path.is_file():
            raise FileNotFoundError(source_path)
        return source_path.open('rb')
