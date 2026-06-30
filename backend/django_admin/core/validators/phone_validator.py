# core/validators/phone_validator.py
import re
from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _

def validate_phone_number(value: str) -> None:
    """
    Validate Kenyan phone numbers.
    Accepts formats: 07XX XXX XXX, 7XX XXX XXX, +2547XXXXXXXX
    """
    # Delegate to normalize_phone_number which performs cleaning and validation
    try:
        normalize_phone_number(value)
    except ValidationError:
        raise


def normalize_phone_number(value: str) -> str:
    """
    Normalize Kenyan phone numbers to international +2547XXXXXXXX format.

    Examples accepted: '0712345678', '712345678', '+254712345678', '254712345678',
    and with spaces/dashes which will be stripped.

    Returns the normalized string like '+254712345678' or raises ValidationError
    if the input is invalid.
    """
    if not isinstance(value, str):
        raise ValidationError(_('Phone number must be a string.'))

    # Remove spaces and dashes
    cleaned = re.sub(r'[\s\-]', '', value)

    # Remove leading plus if present
    if cleaned.startswith('+'):
        cleaned = cleaned[1:]

    # Match Kenyan phone numbers and capture the 9-digit part after leading 0 or 254
    pattern = r'^(?:254|0)?(7\d{8})$'
    match = re.match(pattern, cleaned)
    if not match:
        raise ValidationError(
            _('Enter a valid Kenyan phone number (e.g., 0712345678 or +254712345678).')
        )

    local_part = match.group(1)
    return f'+254{local_part}'