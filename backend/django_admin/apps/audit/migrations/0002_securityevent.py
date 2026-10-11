import django.db.models.deletion
import uuid
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('audit', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='SecurityEvent',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('uuid', models.UUIDField(default=uuid.uuid4, editable=False, unique=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('event_type', models.CharField(db_index=True, max_length=100)),
                ('description', models.TextField()),
                ('severity', models.CharField(choices=[('low', 'Low'), ('medium', 'Medium'), ('high', 'High'), ('critical', 'Critical')], db_index=True, default='medium', max_length=10)),
                ('ip_address', models.GenericIPAddressField(blank=True, null=True)),
                ('request_id', models.CharField(blank=True, db_index=True, max_length=100)),
                ('investigated', models.BooleanField(db_index=True, default=False)),
                ('investigation_notes', models.TextField(blank=True)),
                ('resolved_at', models.DateTimeField(blank=True, null=True)),
                ('metadata', models.JSONField(blank=True, default=dict)),
                ('user', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='security_events', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'db_table': 'security_events',
                'ordering': ['-created_at'],
                'indexes': [
                    models.Index(fields=['event_type', 'created_at'], name='audit_sec_event_created_idx'),
                    models.Index(fields=['severity', 'investigated', 'created_at'], name='audit_sec_sev_inv_created_idx'),
                ],
            },
        ),
    ]