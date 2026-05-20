from django.core.management.base import BaseCommand

from apps.paybill.services.reconciliation import reconcile_orphaned_transactions


class Command(BaseCommand):
    help = "Re-match orphaned PayBill transactions to orders."

    def handle(self, *args, **options):
        reconcile_orphaned_transactions()
        self.stdout.write(self.style.SUCCESS('Orphan reconciliation completed.'))
