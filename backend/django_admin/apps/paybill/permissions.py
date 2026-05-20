from rest_framework import permissions


class CanViewPayBillTransactions(permissions.BasePermission):
    """Allow only staff or users with explicit paybill view permission."""

    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and (
                request.user.is_staff
                or request.user.has_perm('paybill.view_paybilltransaction')
            )
        )
