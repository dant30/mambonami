import uuid

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('users', '0009_transportproviderprofile_acceptance_rate_and_more')]

    operations = [
        migrations.CreateModel(
            name='PendingRegistration',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('uuid', models.UUIDField(default=uuid.uuid4, editable=False, unique=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('registration_id', models.UUIDField(db_index=True, default=uuid.uuid4, editable=False, unique=True)),
                ('phone', models.CharField(db_index=True, max_length=15)),
                ('role', models.CharField(max_length=30)),
                ('registration_data', models.JSONField(default=dict)),
                ('password_hash', models.CharField(max_length=256)),
                ('otp_hash', models.CharField(max_length=128)),
                ('otp_expires_at', models.DateTimeField()),
                ('attempt_count', models.PositiveSmallIntegerField(default=0)),
                ('resend_count', models.PositiveSmallIntegerField(default=0)),
                ('status', models.CharField(choices=[('pending', 'Pending'), ('verified', 'Verified'), ('expired', 'Expired'), ('blocked', 'Blocked'), ('cancelled', 'Cancelled')], db_index=True, default='pending', max_length=20)),
                ('verified_at', models.DateTimeField(blank=True, null=True)),
            ],
            options={'db_table': 'pending_registrations', 'ordering': ['-created_at']},
        ),
    ]
