# core/validators/phone_validator.py
import re
from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _

def validate_phone_number(value: str) -> None:
    """
    Validate Kenyan phone numbers.
    Accepts formats: 07XX XXX XXX, 7XX XXX XXX, +2547XXXXXXXX
    """
    # Remove any spaces, dashes, or plus sign
    cleaned = re.sub(r'[\s\-]', '', value)
    if cleaned.startswith('+'):
        cleaned = cleaned[1:]
    
    # Check if it's a valid Kenyan number
    pattern = r'^(?:254|0)?(7\d{8})$'
    match = re.match(pattern, cleaned)
    if not match:
        raise ValidationError(
            _('Enter a valid Kenyan phone number (e.g., 0712345678 or +254712345678).')
        )