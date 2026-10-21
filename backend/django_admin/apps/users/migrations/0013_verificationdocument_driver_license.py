from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0012_user_referral'),
    ]

    operations = [
        migrations.AlterField(
            model_name='verificationdocument',
            name='document_type',
            field=models.CharField(
                choices=[
                    ('national_id', 'National ID'),
                    ('business_license', 'Business License'),
                    ('coop_certificate', 'Cooperative Certificate'),
                    ('driver_license', 'Driver License'),
                    ('other', 'Other'),
                ],
                max_length=30,
            ),
        ),
    ]