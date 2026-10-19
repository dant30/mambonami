import core.storage_backends
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('logistics', '0005_tripproviderdecline'),
    ]

    operations = [
        migrations.AlterField(
            model_name='trip',
            name='buyer_signature',
            field=models.ImageField(
                blank=True,
                null=True,
                storage=core.storage_backends.PrivateMediaStorage(),
                upload_to='signatures/',
            ),
        ),
        migrations.AlterField(
            model_name='tripmedia',
            name='image',
            field=models.ImageField(
                storage=core.storage_backends.PrivateMediaStorage(),
                upload_to='trips/media/',
            ),
        ),
    ]
