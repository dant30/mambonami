# Generated migration for adding type field to Notification

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('notifications', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='notification',
            name='type',
            field=models.CharField(
                choices=[
                    ('payment', 'Payment'),
                    ('order', 'Order'),
                    ('delivery', 'Delivery'),
                    ('review', 'Review'),
                    ('alert', 'Alert'),
                ],
                default='alert',
                help_text='Notification type for UI icon selection',
                max_length=20,
            ),
        ),
    ]
