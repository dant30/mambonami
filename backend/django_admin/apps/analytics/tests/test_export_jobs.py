from django.test import TestCase
from apps.analytics.models import AnalyticsExportJob
from apps.users.models import User


class AnalyticsExportJobTests(TestCase):
    def test_export_job_can_be_created(self):
        user = User.objects.create_user(
            phone='+254700000005',
            username='export-user',
            password='StrongPass123!',
            role='buyer',
        )
        job = AnalyticsExportJob.objects.create(
            requested_by=user,
            export_format='csv',
            filters={'days': 30},
            status='queued',
        )
        self.assertEqual(job.export_format, 'csv')
        self.assertEqual(job.status, 'queued')
