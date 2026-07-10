# django_admin/apps/logistics/models/transport_provider.py
# backend/django_admin/apps/logistics/models/transport_provider.py
"""
Transport provider model is defined in `apps.users.models.TransportProviderProfile`.
To avoid import-time coupling, reference it lazily in model fields using the
string form 'users.TransportProviderProfile' (e.g. `models.ForeignKey('users.TransportProviderProfile', ...)`).
"""