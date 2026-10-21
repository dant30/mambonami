import uuid
import apps.users.models.user

from django.db import migrations, models
import django.db.models.deletion


def populate_referral_codes(apps, schema_editor):
    User = apps.get_model('users', 'User')
    database = schema_editor.connection.alias
    for user in User.objects.using(database).filter(referral_code__isnull=True).iterator():
        user.referral_code = uuid.uuid4().hex[:12].upper()
        user.save(update_fields=['referral_code'], using=database)


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0011_merge_20261019_2228'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='referral_code',
            field=models.CharField(blank=True, max_length=12, null=True),
        ),
        migrations.AddField(
            model_name='user',
            name='referred_by',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='referrals', to='users.user'),
        ),
        migrations.RunPython(populate_referral_codes, migrations.RunPython.noop),
        migrations.AlterField(
            model_name='user',
            name='referral_code',
            field=models.CharField(default=apps.users.models.user.generate_referral_code, editable=False, max_length=12, unique=True),
        ),
    ]