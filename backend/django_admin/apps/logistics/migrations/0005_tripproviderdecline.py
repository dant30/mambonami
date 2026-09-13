import uuid
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    dependencies = [
        ('logistics', '0004_triplocationping_tripmedia_tripstatushistory_and_more'),
        ('users', '0008_remove_farmerprofile_avatar_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='TripProviderDecline',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('uuid', models.UUIDField(default=uuid.uuid4, editable=False, unique=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('reason', models.TextField(blank=True)),
                ('provider', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='trip_declines', to='users.transportproviderprofile')),
                ('trip', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='provider_declines', to='logistics.trip')),
            ],
            options={'db_table': 'trip_provider_declines'},
        ),
        migrations.AddConstraint(
            model_name='tripproviderdecline',
            constraint=models.UniqueConstraint(fields=('trip', 'provider'), name='unique_trip_provider_decline'),
        ),
    ]