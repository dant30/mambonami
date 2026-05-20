# core/validators/price_validator.py
from decimal import Decimal
from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _

def validate_positive_price(value: Decimal) -> None:
    """Ensure price is greater than zero."""
    if value <= 0:
        raise ValidationError(_('Price must be greater than zero.'))