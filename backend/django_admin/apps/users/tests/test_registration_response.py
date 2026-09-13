from unittest.mock import patch

from django.contrib.auth.models import AnonymousUser
from django.test import SimpleTestCase, TestCase
from rest_framework.test import APIRequestFactory
from rest_framework.views import APIView

from apps.users.models import Role, User
from apps.users.serializers.user_serializer import RegistrationStartSerializer, UserDetailSerializer, VerifyOTPSerializer
from apps.users.views.api import CustomTokenObtainPairView
from core.throttling import BurstThrottle


class RegistrationResponseTests(TestCase):
    def test_user_detail_serializer_includes_role_and_phone(self):
        user = User.objects.create_user(
            phone='+254700000000',
            username='regtest',
            password='TestPass123!',
            role=Role.BUYER,
        )

        data = UserDetailSerializer(user).data

        self.assertEqual(data['phone'], '+254700000000')
        self.assertEqual(data['role'], Role.BUYER)
        self.assertIn('username', data)


class ThrottlingFallbackTests(SimpleTestCase):
    def test_burst_throttle_allows_request_when_cache_backend_fails(self):
        throttle = BurstThrottle()
        throttle.num_requests = 5
        factory = APIRequestFactory()
        request = factory.post('/')
        request.user = AnonymousUser()

        with patch('rest_framework.throttling.SimpleRateThrottle.allow_request', side_effect=Exception('cache down')):
            self.assertTrue(throttle.allow_request(request, APIView()))


class TransportVehicleTypeTests(TestCase):
    @patch('apps.users.serializers.user_serializer.RedisCache.delete')
    @patch('apps.users.serializers.user_serializer.RedisCache.set')
    @patch('apps.users.serializers.user_serializer.RedisCache.get', return_value=0)
    @patch('apps.users.serializers.user_serializer.get_otp', return_value='123456')
    def test_transport_vehicle_type_accepts_display_label(self, _otp_mock, _get_mock, _set_mock, _delete_mock):
        serializer = VerifyOTPSerializer(data={
            'phone': '+254700000000',
            'otp': '123456',
            'username': 'transportuser',
            'password': 'TestPass123!',
            'confirm_password': 'TestPass123!',
            'role': Role.TRANSPORT_PROVIDER,
            'vehicle_type': 'Pickup',
            'license_plate': 'KAA 123A',
        })

        self.assertTrue(serializer.is_valid(), serializer.errors)
        self.assertEqual(serializer.validated_data['vehicle_type'], 'pickup')


class RegistrationStartSerializerTests(TestCase):
    def test_registration_start_accepts_minimal_account_details(self):
        serializer = RegistrationStartSerializer(
            data={
                'phone': '+254700000000',
                'role': Role.BUYER,
                'username': 'newbuyer',
                'password': 'TestPass123!',
                'confirm_password': 'TestPass123!',
            }
        )

        self.assertTrue(serializer.is_valid(), serializer.errors)


class LoginViewFallbackTests(TestCase):
    def test_login_returns_user_payload_when_user_serializer_raises(self):
        user = User.objects.create_user(
            phone='+254700000001',
            username='logintest',
            password='TestPass123!',
            role=Role.BUYER,
        )

        factory = APIRequestFactory()
        request = factory.post(
            '/api/users/login/',
            {'phone': '+254700000001', 'password': 'TestPass123!'},
            format='json',
        )
        request.user = AnonymousUser()

        class BrokenUserSerializer:
            def __init__(self, *args, **kwargs):
                pass

            @property
            def data(self):
                raise RuntimeError('serializer exploded')

        response = None
        with patch('apps.users.views.api.UserDetailSerializer', BrokenUserSerializer):
            response = CustomTokenObtainPairView.as_view()(request)

        self.assertEqual(response.status_code, 200)
        self.assertIn('tokens', response.data)
        self.assertEqual(response.data['user']['phone'], user.phone)
