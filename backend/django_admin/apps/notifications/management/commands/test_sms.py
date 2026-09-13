from django.core.management.base import BaseCommand

from apps.notifications.services.sms import OTSSMS


class Command(BaseCommand):
    help = 'Test OTS SMS integration'

    def add_arguments(self, parser):
        parser.add_argument('phone', type=str, help='Phone number to send test SMS to')

    def handle(self, *args, **options):
        sms = OTSSMS()
        result = sms.send_sms(options['phone'], 'Test message from MAMBONAMI')
        self.stdout.write(f'Result: {result}')