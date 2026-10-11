from rest_framework import permissions
from apps.users.permissions import is_admin_user


class CanViewPayBillTransactions(permissions.BasePermission):
    """Allow only staff or users with explicit paybill view permission."""

    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and (
                is_admin_user(request.user)
                or request.user.has_perm('paybill.view_paybilltransaction')
            )
        )
