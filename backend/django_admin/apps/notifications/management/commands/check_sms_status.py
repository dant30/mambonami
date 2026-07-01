from django.core.management.base import BaseCommand

from apps.notifications.services.sms import OTSSMS


class Command(BaseCommand):
    help = 'Check OTS SMS queue delivery status'

    def add_arguments(self, parser):
        parser.add_argument('queue_uid', type=str, help='OTS queue_uid returned by test_sms or logs')

    def handle(self, *args, **options):
        sms = OTSSMS()
        result = sms.check_queue_status(options['queue_uid'])
        self.stdout.write(f'Result: {result}')
