from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0005_promocode_order_discount_amount_order_promo_code'),
    ]

    operations = [
        migrations.AddField(
            model_name='order',
            name='fulfillment_type',
            field=models.CharField(
                choices=[('delivery', 'Delivery'), ('self_pickup', 'Self Pickup')],
                default='delivery',
                max_length=20,
            ),
        ),
    ]