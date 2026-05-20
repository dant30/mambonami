# core/validators/id_number_validator.py
from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _

def validate_id_number(value: str) -> None:
    """
    Basic validation for Kenyan ID numbers.
    IDs are 8 digits (some older ones are 7 or 6 digits).
    """
    if not value.isdigit():
        raise ValidationError(_('ID number must contain only digits.'))
    
    if len(value) < 5 or len(value) > 8:
        raise ValidationError(_('ID number must be between 5 and 8 digits.'))