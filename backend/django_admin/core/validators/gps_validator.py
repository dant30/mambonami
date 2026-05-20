# core/validators/gps_validator.py
from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _

def validate_gps_coordinates(value: str) -> None:
    """
    Validate GPS coordinate string in format "lat,lng".
    Latitude: -90 to 90, Longitude: -180 to 180.
    """
    try:
        lat_str, lng_str = value.split(',')
        lat = float(lat_str.strip())
        lng = float(lng_str.strip())
        if not (-90 <= lat <= 90):
            raise ValidationError(_('Latitude must be between -90 and 90.'))
        if not (-180 <= lng <= 180):
            raise ValidationError(_('Longitude must be between -180 and 180.'))
    except (ValueError, AttributeError):
        raise ValidationError(_('GPS coordinates must be in format "lat,lng" (e.g., "-1.2921,36.8219").'))