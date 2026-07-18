from unittest.mock import patch

from django.contrib.auth.models import AnonymousUser
from django.test import SimpleTestCase, TestCase
from rest_framework.test import APIRequestFactory
from rest_framework.views import APIView

from apps.users.models import Role, User
from apps.users.serializers.user_serializer import UserDetailSerializer
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
