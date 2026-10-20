import django.core.validators
import django.db.models.deletion
import uuid
from django.db import migrations, models
from decimal import Decimal


class Migration(migrations.Migration):

    dependencies = [
        ('products', '0014_alter_product_price_per_unit'),
    ]

    operations = [
        migrations.CreateModel(
            name='BulkPriceTier',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('uuid', models.UUIDField(default=uuid.uuid4, editable=False, unique=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('buyer_role', models.CharField(choices=[('any', 'Any buyer'), ('buyer', 'Consumer'), ('retailer', 'Retailer')], default='any', max_length=20)),
                ('minimum_quantity', models.DecimalField(decimal_places=2, max_digits=12, validators=[django.core.validators.MinValueValidator(Decimal('0.01'))])),
                ('unit_price', models.DecimalField(decimal_places=2, max_digits=10, validators=[django.core.validators.MinValueValidator(Decimal('0.01'))])),
                ('is_active', models.BooleanField(default=True)),
                ('product', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='bulk_price_tiers', to='products.product')),
            ],
            options={
                'db_table': 'bulk_price_tiers',
                'ordering': ['product', 'buyer_role', '-minimum_quantity'],
            },
        ),
        migrations.AddConstraint(
            model_name='bulkpricetier',
            constraint=models.UniqueConstraint(fields=('product', 'buyer_role', 'minimum_quantity'), name='unique_product_role_bulk_tier'),
        ),
    ]