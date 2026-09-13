# backend/django_admin/apps/paybill/services/account_number.py
from django.db import transaction
from apps.paybill.models import AccountNumberReservation

def generate_account_number(prefix: str, related_object_id: int, related_object_type: str) -> str:
    """
    Generate a unique PayBill account number with optional reservation tracking.
    Example: ORD-12345, DEP-TRANSPORT-42, REF-9876
    """
    # Validate prefix
    allowed_prefixes = dict(AccountNumberReservation.ACCOUNT_PREFIXES)
    if prefix not in allowed_prefixes:
        raise ValueError(f"Invalid prefix. Use one of: {', '.join(allowed_prefixes.keys())}")

    # Build account number
    account_number = f"{prefix}-{related_object_id}"

    # (Optional) reserve it in the tracking table
    with transaction.atomic():
        AccountNumberReservation.objects.get_or_create(
            prefix=prefix,
            related_object_id=related_object_id,
            related_object_type=related_object_type,
            defaults={
                'account_number': account_number,
                'is_used': False,
            }
        )
    return account_number

def reserve_account_number(prefix: str, related_object_id: int, related_object_type: str) -> str:
    """Alias for generate_account_number, with stronger emphasis on reservation."""
    return generate_account_number(prefix, related_object_id, related_object_type)


def generate_transport_deposit_account(provider_id: int) -> str:
    """Reserve the PayBill reference used for a transport provider deposit."""
    account_number = f'DEP-TRANSPORT-{provider_id}'
    with transaction.atomic():
        AccountNumberReservation.objects.get_or_create(
            prefix='DEP',
            related_object_id=provider_id,
            related_object_type='TransportProviderProfile',
            defaults={'account_number': account_number, 'is_used': False},
        )
    return account_number