# django_admin/apps/logistics/tests/test_fee_calculator.py
from decimal import Decimal
from django.test import TestCase
from django.contrib.auth import get_user_model
from apps.users.models import TransportProviderProfile
from apps.logistics.services.fee_calculator import (
    calculate_delivery_fee,
    calculate_waiting_surcharge,
    get_default_rates_for_vehicle_type,
    estimate_fee,
)

User = get_user_model()


class FeeCalculatorTests(TestCase):
    """Test delivery fee calculation logic."""

    def setUp(self):
        """Create test users and provider profiles."""
        self.user_motorcycle = User.objects.create_user(
            phone="254712000001",
            role="transport_provider",
            username="moto_rider"
        )
        self.user_pickup = User.objects.create_user(
            phone="254712000002",
            role="transport_provider",
            username="pickup_driver"
        )

        # Motorcycle provider with default rates
        self.provider_motorcycle, _ = TransportProviderProfile.objects.get_or_create(
            user=self.user_motorcycle,
            defaults={
                'vehicle_type': 'motorcycle',
                'capacity_kg': 50,
                'license_plate': 'KCA123A',
                'driver_license': 'DL123456',
                'deposit_paid': True,
                'is_approved': True,
            }
        )
        if not self.provider_motorcycle.is_approved or not self.provider_motorcycle.deposit_paid:
            self.provider_motorcycle.vehicle_type = 'motorcycle'
            self.provider_motorcycle.capacity_kg = 50
            self.provider_motorcycle.license_plate = 'KCA123A'
            self.provider_motorcycle.driver_license = 'DL123456'
            self.provider_motorcycle.deposit_paid = True
            self.provider_motorcycle.is_approved = True
            self.provider_motorcycle.save()

        # Pickup provider with custom rates
        self.provider_pickup, _ = TransportProviderProfile.objects.get_or_create(
            user=self.user_pickup,
            defaults={
                'vehicle_type': 'pickup',
                'capacity_kg': 500,
                'license_plate': 'KCA456B',
                'driver_license': 'DL789012',
                'deposit_paid': True,
                'is_approved': True,
                'base_rate_per_km': Decimal('45.00'),
                'waiting_grace_minutes': 20,
                'waiting_rate_per_min': Decimal('2.50'),
            }
        )
        if not self.provider_pickup.is_approved or not self.provider_pickup.deposit_paid:
            self.provider_pickup.vehicle_type = 'pickup'
            self.provider_pickup.capacity_kg = 500
            self.provider_pickup.license_plate = 'KCA456B'
            self.provider_pickup.driver_license = 'DL789012'
            self.provider_pickup.deposit_paid = True
            self.provider_pickup.is_approved = True
            self.provider_pickup.base_rate_per_km = Decimal('45.00')
            self.provider_pickup.waiting_grace_minutes = 20
            self.provider_pickup.waiting_rate_per_min = Decimal('2.50')
            self.provider_pickup.save()


    def test_motorcycle_base_rate(self):
        """Test motorcycle provider base rate (25 KES/km)."""
        # 10 km, 25 kg (under capacity), no waiting
        fee = calculate_delivery_fee(
            distance_km=10,
            total_weight_kg=25,
            provider=self.provider_motorcycle,
            waiting_minutes=0
        )
        # Expected: 10 * 25 = 250, rounded to 250
        self.assertEqual(fee, Decimal('250.00'))

    def test_weight_penalty_motorcycle(self):
        """Test weight penalty when over capacity."""
        # 10 km, 75 kg (25 kg over 50 capacity), no waiting
        fee = calculate_delivery_fee(
            distance_km=10,
            total_weight_kg=75,
            provider=self.provider_motorcycle,
            waiting_minutes=0
        )
        # Expected: (10 * 25) + (25 * 10) = 250 + 250 = 500, rounded to 500
        self.assertEqual(fee, Decimal('500.00'))

    def test_waiting_surcharge_within_grace_period(self):
        """Test waiting surcharge within grace period (should be 0)."""
        # 10 km, 25 kg, 5 minutes waiting (within 15 min grace for motorcycle)
        fee = calculate_delivery_fee(
            distance_km=10,
            total_weight_kg=25,
            provider=self.provider_motorcycle,
            waiting_minutes=5
        )
        # Expected: no surcharge within grace period
        # (10 * 25) = 250, rounded to 250
        self.assertEqual(fee, Decimal('250.00'))

    def test_waiting_surcharge_exceeds_grace_period(self):
        """Test waiting surcharge when grace period exceeded."""
        # 10 km, 25 kg, 25 minutes waiting (10 min over 15 min grace for motorcycle)
        fee = calculate_delivery_fee(
            distance_km=10,
            total_weight_kg=25,
            provider=self.provider_motorcycle,
            waiting_minutes=25
        )
        # Expected: (10 * 25) + (10 * 2) = 250 + 20 = 270, rounded to 270
        self.assertEqual(fee, Decimal('270.00'))

    def test_combined_penalties(self):
        """Test combined weight and waiting penalties."""
        # 10 km, 100 kg (50 kg over capacity), 30 min waiting (15 min over grace)
        fee = calculate_delivery_fee(
            distance_km=10,
            total_weight_kg=100,
            provider=self.provider_motorcycle,
            waiting_minutes=30
        )
        # Expected: (10 * 25) + (50 * 10) + (15 * 2) = 250 + 500 + 30 = 780, rounded to 780
        self.assertEqual(fee, Decimal('780.00'))

    def test_pickup_provider_different_rates(self):
        """Test pickup provider with custom rates."""
        # 20 km, 300 kg (under 500 capacity), 10 min waiting (within 20 min grace)
        fee = calculate_delivery_fee(
            distance_km=20,
            total_weight_kg=300,
            provider=self.provider_pickup,
            waiting_minutes=10
        )
        # Expected: 20 * 45 = 900, rounded to 900
        self.assertEqual(fee, Decimal('900.00'))

    def test_pickup_provider_with_surcharge(self):
        """Test pickup provider with waiting surcharge."""
        # 20 km, 300 kg, 45 min waiting (25 min over 20 min grace)
        fee = calculate_delivery_fee(
            distance_km=20,
            total_weight_kg=300,
            provider=self.provider_pickup,
            waiting_minutes=45
        )
        # Expected: (20 * 45) + (25 * 2.5) = 900 + 62.5 = 962.5, rounded to 965
        self.assertEqual(fee, Decimal('965.00'))

    def test_rounding_to_nearest_5_kes(self):
        """Test rounding to nearest 5 KES."""
        # Various distances that should round up
        test_cases = [
            (10.1, 25, 0, Decimal('255.00')),  # 10.1 * 25 = 252.5 -> 255
            (10.2, 25, 0, Decimal('255.00')),  # 10.2 * 25 = 255 -> 255
            (10.3, 25, 0, Decimal('260.00')),  # 10.3 * 25 = 257.5 -> 260
        ]
        for distance, weight, waiting, expected_fee in test_cases:
            fee = calculate_delivery_fee(
                distance_km=distance,
                total_weight_kg=weight,
                provider=self.provider_motorcycle,
                waiting_minutes=waiting
            )
            self.assertEqual(fee, expected_fee, 
                f"Failed for distance={distance}, expected {expected_fee}, got {fee}")

    def test_calculate_waiting_surcharge_isolated(self):
        """Test waiting surcharge calculation in isolation."""
        # 5 min within grace period
        surcharge = calculate_waiting_surcharge(self.provider_motorcycle, 5)
        self.assertEqual(surcharge, Decimal('0.00'))

        # 20 min (5 min over 15 min grace)
        surcharge = calculate_waiting_surcharge(self.provider_motorcycle, 20)
        self.assertEqual(surcharge, Decimal('10.00'))

        # Pickup provider: 40 min (20 min over 20 min grace)
        surcharge = calculate_waiting_surcharge(self.provider_pickup, 40)
        self.assertEqual(surcharge, Decimal('50.00'))

    def test_get_default_rates_for_vehicle_type(self):
        """Test default rates retrieval by vehicle type."""
        rates = get_default_rates_for_vehicle_type('motorcycle')
        self.assertEqual(rates['base_rate_per_km'], Decimal('25.00'))
        self.assertEqual(rates['waiting_grace_minutes'], 10)
        self.assertEqual(rates['waiting_rate_per_min'], Decimal('2.00'))

        rates = get_default_rates_for_vehicle_type('pickup')
        self.assertEqual(rates['base_rate_per_km'], Decimal('45.00'))
        self.assertEqual(rates['waiting_grace_minutes'], 20)

        rates = get_default_rates_for_vehicle_type('van')
        self.assertEqual(rates['base_rate_per_km'], Decimal('50.00'))

        rates = get_default_rates_for_vehicle_type('lorry')
        self.assertEqual(rates['base_rate_per_km'], Decimal('75.00'))

    def test_estimate_fee_without_provider_instance(self):
        """Test fee estimation for frontend (no provider instance)."""
        # 15 km, 40 kg, motorcycle type
        fee = estimate_fee(
            distance_km=15,
            total_weight_kg=40,
            vehicle_type='motorcycle',
            capacity_kg=50
        )
        # Expected: 15 * 25 = 375, rounded to 375
        self.assertEqual(fee, Decimal('375.00'))

        # 15 km, 150 kg (100 kg over 50 capacity)
        fee = estimate_fee(
            distance_km=15,
            total_weight_kg=150,
            vehicle_type='motorcycle',
            capacity_kg=50
        )
        # Expected: (15 * 25) + (100 * 10) = 375 + 1000 = 1375, rounded to 1375
        self.assertEqual(fee, Decimal('1375.00'))

    def test_zero_distance(self):
        """Test edge case: zero distance."""
        fee = calculate_delivery_fee(
            distance_km=0,
            total_weight_kg=50,
            provider=self.provider_motorcycle,
            waiting_minutes=0
        )
        # Expected: 0 * 25 = 0, rounded to 0
        self.assertEqual(fee, Decimal('0.00'))

    def test_large_distance_and_weight(self):
        """Test large distances and weights."""
        # 100 km, 200 kg (150 kg over 50 capacity), 60 min waiting (45 min over grace)
        fee = calculate_delivery_fee(
            distance_km=100,
            total_weight_kg=200,
            provider=self.provider_motorcycle,
            waiting_minutes=60
        )
        # Expected: (100 * 25) + (150 * 10) + (45 * 2) = 2500 + 1500 + 90 = 4090, rounded to 4090
        self.assertEqual(fee, Decimal('4090.00'))
