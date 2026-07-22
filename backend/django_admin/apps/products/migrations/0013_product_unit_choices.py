from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('products', '0012_product_min_stock_level'),
    ]

    operations = [
        migrations.AlterField(
            model_name='product',
            name='unit',
            field=models.CharField(
                choices=[
                    ('kg', 'Kilogram'),
                    ('piece', 'Piece'),
                    ('litre', 'Litre'),
                    ('tray', 'Tray'),
                    ('bunch', 'Bunch'),
                    ('bag', 'Bag'),
                    ('crate', 'Crate'),
                    ('box', 'Box'),
                ],
                help_text='Unit of measurement',
                max_length=20,
            ),
        ),
    ]
