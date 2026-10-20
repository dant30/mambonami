from decimal import Decimal

from django.db.models import Case, IntegerField, Value, When

from apps.products.models import BulkPriceTier, Product


def resolve_unit_price(product: Product, buyer_role: str, quantity: Decimal) -> Decimal:
    """Choose the highest eligible fixed-price tier; role-specific wins ties with any."""
    tier = (
        BulkPriceTier.objects.filter(
            product=product,
            is_active=True,
            minimum_quantity__lte=quantity,
            buyer_role__in=[buyer_role, 'any'],
        )
        .annotate(
            role_priority=Case(
                When(buyer_role=buyer_role, then=Value(0)),
                default=Value(1),
                output_field=IntegerField(),
            )
        )
        .order_by('-minimum_quantity', 'role_priority', 'pk')
        .first()
    )
    return tier.unit_price if tier else product.price_per_unit