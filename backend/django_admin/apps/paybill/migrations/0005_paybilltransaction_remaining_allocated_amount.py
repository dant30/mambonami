from decimal import Decimal

from django.db import migrations, models
from django.db.models import Sum


def backfill_remaining_allocated_amount(apps, schema_editor):
    PayBillTransaction = apps.get_model('paybill', 'PayBillTransaction')
    PaymentAllocation = apps.get_model('paybill', 'PaymentAllocation')
    database = schema_editor.connection.alias

    allocated_totals = {
        transaction_id: total
        for transaction_id, total in (
            PaymentAllocation.objects.using(database)
            .exclude(allocation_type='refund')
            .values_list('transaction_id')
            .annotate(total=Sum('amount'))
        )
    }
    transactions = PayBillTransaction.objects.using(database).only('pk')
    for payment in transactions.iterator(chunk_size=1000):
        payment.remaining_allocated_amount = allocated_totals.get(payment.pk, Decimal('0.00'))
        payment.save(update_fields=['remaining_allocated_amount'], using=database)


class Migration(migrations.Migration):

    dependencies = [
        ('paybill', '0004_stkpushrequest'),
    ]

    operations = [
        migrations.AddField(
            model_name='paybilltransaction',
            name='remaining_allocated_amount',
            field=models.DecimalField(
                decimal_places=2,
                default=0,
                help_text='Unrefunded amount allocated to orders or other purposes',
                max_digits=12,
            ),
        ),
        migrations.RunPython(
            backfill_remaining_allocated_amount,
            migrations.RunPython.noop,
        ),
    ]