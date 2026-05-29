import os
import sys
import pathlib
import django
from decimal import Decimal
from datetime import datetime, timedelta

WORKSPACE_ROOT = pathlib.Path(__file__).resolve().parents[3]
DJANGO_ADMIN_DIR = pathlib.Path(__file__).resolve().parents[1]
# Ensure Django project package (`config`) is importable and top-level shared package is available
sys.path.insert(0, str(DJANGO_ADMIN_DIR))
sys.path.insert(0, str(WORKSPACE_ROOT))
print('Inserted paths for imports:')
print('  workspace_root=', WORKSPACE_ROOT)
print('  django_admin_dir=', DJANGO_ADMIN_DIR)
print('  shared exists?', (WORKSPACE_ROOT / 'shared').is_dir())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.dev')
django.setup()

from django.utils import timezone
from django.contrib.auth import get_user_model
from apps.users.models import FarmerProfile, TransportProviderProfile
from apps.products.models import Product
from apps.orders.services import create_order_from_cart
from apps.logistics.services.matching import find_eligible_providers, assign_provider_to_order
from apps.logistics.services.fee_calculator import calculate_waiting_surcharge
from apps.payouts import services as payout_services
from apps.logistics.models import Trip
from django.db import transaction

User = get_user_model()

print('Starting E2E simulation')

with transaction.atomic():
    # 1. Create farmer
    farmer_user, _ = User.objects.get_or_create(phone='254700000001', defaults={'username':'farmer1', 'role':'farmer'})
    farmer_profile, _ = FarmerProfile.objects.get_or_create(user=farmer_user)
    farmer_profile.farm_gps = ' -1.2921,36.8219'.strip()
    farmer_profile.save()

    # 2. Create product with pickup GPS and weight
    product_defaults = {
        'price_per_unit': Decimal('100.00'),
        'available_quantity': Decimal('10'),
        'unit': 'kg',
        'harvest_date': datetime.today().date(),
    }
    # If Product has category FK, ensure a valid category exists
    if hasattr(Product, 'category') or hasattr(Product, 'category_id'):
        try:
            from apps.products.models import ProductCategory
            category, _ = ProductCategory.objects.get_or_create(name='SimCategory')
            product_defaults['category'] = category
        except Exception:
            pass

    product, _ = Product.objects.get_or_create(farmer=farmer_profile, name='Test Mango', defaults=product_defaults)
    # Ensure pickup GPS
    product.pickup_lat = Decimal('-1.2921')
    product.pickup_lng = Decimal('36.8219')
    # attach weight_per_unit dynamically for simulation
    setattr(product, 'weight_per_unit', Decimal('5.0'))
    product.save()

    # 3. Create buyer
    buyer, _ = User.objects.get_or_create(phone='254700000002', defaults={'username':'buyer1', 'role':'buyer'})

    # 4. Prepare grouped_products for create_order_from_cart
    grouped_products = {
        farmer_profile.id: [
            {'product': product, 'quantity': Decimal('1.0')}
        ]
    }

    cart_data = {
        'grouped_products': grouped_products,
        'delivery_address': 'Nairobi CBD',
        'delivery_lat': Decimal('-1.28333'),
        'delivery_lng': Decimal('36.81667'),
        'scheduled_date': datetime.today().date(),
        'scheduled_time_window': '10:00-12:00',
        'items': [
            {'product_uuid': product.uuid, 'quantity': Decimal('1.0')}
        ]
    }

    order = create_order_from_cart(buyer, cart_data)
    print(f'Order created: id={order.id}, total_amount={order.total_amount}, total_weight_kg={order.total_weight_kg}')

    # 5. Create a transport provider eligible
    provider_user, _ = User.objects.get_or_create(phone='254700000003', defaults={'username':'provider1', 'role':'transport_provider'})
    provider_profile, _ = TransportProviderProfile.objects.get_or_create(user=provider_user)
    provider_profile.deposit_paid = True
    provider_profile.is_approved = True
    provider_profile.capacity_kg = 100
    provider_profile.base_rate_per_km = Decimal('30.00')
    provider_profile.waiting_grace_minutes = 10
    provider_profile.waiting_rate_per_min = Decimal('2.00')
    provider_profile.save()

    # 6. Find eligible providers
    eligible = find_eligible_providers(order)
    print(f'Eligible providers found: {len(eligible)}')
    if not eligible:
        print('No eligible providers found; aborting simulation')
    else:
        provider, est_fee = eligible[0]
        print(f'Assigning provider {provider.id} with estimated fee {est_fee}')
        trip = assign_provider_to_order(order, provider)
        print(f'Trip created: {trip.id}, agreed_fee={trip.agreed_fee}')

        # 7. Simulate arrival 20 minutes ago
        trip.arrived_at_farm = timezone.now() - timedelta(minutes=20)
        trip.save(update_fields=['arrived_at_farm'])
        waiting_minutes = int((timezone.now() - trip.arrived_at_farm).total_seconds() / 60)
        surcharge = calculate_waiting_surcharge(provider, waiting_minutes)
        trip.waiting_surcharge = surcharge
        trip.status = 'picked_up'
        trip.picked_up_at = timezone.now()
        trip.save(update_fields=['waiting_surcharge','status','picked_up_at'])
        print(f'Pickup recorded. waiting_minutes={waiting_minutes}, surcharge={surcharge}, total_fee={trip.agreed_fee + trip.waiting_surcharge}')

        # 8. Simulate delivery confirmation
        order.status = 'delivered'
        order.delivered_at = timezone.now()
        order.save(update_fields=['status','delivered_at'])

        # 9. Stub out external payouts executor to avoid network calls
        def _noop_execute(payout):
            payout.status = 'processing'
            payout.save(update_fields=['status'])
        payout_services._execute_payout = _noop_execute
        # Also stub float balance check to ensure release proceeds in simulation
        from decimal import Decimal
        # Override float balance check in the actual payout_service module
        import importlib
        payout_service_module = importlib.import_module('apps.payouts.services.payout_service')
        payout_service_module.get_estimated_float_balance = lambda: Decimal('100000.00')

        # 10. Release payments
        payout_services.release_payment(order.id)
        print('Payouts scheduled (simulated).')

print('E2E simulation complete')
