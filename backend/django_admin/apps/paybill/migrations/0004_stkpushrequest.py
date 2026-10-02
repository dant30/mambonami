import django.db.models.deletion
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('orders', '0005_promocode_order_discount_amount_order_promo_code'),
        ('paybill', '0003_paybillsettlement_paymentallocation_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='StkPushRequest',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('uuid', models.UUIDField(default=uuid.uuid4, editable=False, unique=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('phone_number', models.CharField(max_length=15)),
                ('amount', models.DecimalField(decimal_places=2, max_digits=10)),
                ('status', models.CharField(choices=[('initiating', 'Initiating'), ('pending', 'Pending'), ('succeeded', 'Succeeded'), ('failed', 'Failed')], db_index=True, default='initiating', max_length=20)),
                ('merchant_request_id', models.CharField(blank=True, max_length=100)),
                ('checkout_request_id', models.CharField(blank=True, max_length=100, null=True, unique=True)),
                ('result_code', models.IntegerField(blank=True, null=True)),
                ('result_description', models.TextField(blank=True)),
                ('callback_payload', models.JSONField(blank=True, default=dict)),
                ('order', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='stk_push_requests', to='orders.order')),
            ],
            options={
                'db_table': 'paybill_stk_push_requests',
                'ordering': ['-created_at'],
            },
        ),
        migrations.AddIndex(
            model_name='stkpushrequest',
            index=models.Index(fields=['order', 'status'], name='paybill_stk_order_i_772ba7_idx'),
        ),
    ]
