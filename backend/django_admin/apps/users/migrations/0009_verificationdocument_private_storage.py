import core.storage_backends
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0008_remove_farmerprofile_avatar_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='verificationdocument',
            name='file',
            field=models.FileField(
                blank=True,
                null=True,
                storage=core.storage_backends.PrivateMediaStorage(),
                upload_to='verification/',
            ),
        ),
    ]
