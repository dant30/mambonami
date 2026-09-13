#!/usr/bin/env python
"""Idempotently seed the development users shown in the admin user list.

Run from the repository root in PowerShell:
    $env:SEED_PASSWORD = 'YourDevPassword123!'
    python scripts/seed_data.py

The default password is intentionally development-only. Existing passwords,
verification flags, and admin flags are preserved unless --reset-password or
--staff is explicitly supplied.
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DJANGO_ROOT = PROJECT_ROOT / 'backend' / 'django_admin'
sys.path.insert(0, str(PROJECT_ROOT))
sys.path.insert(0, str(DJANGO_ROOT))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.prod')

import django


django.setup()

from apps.users.models import (  # noqa: E402
    AccountStatus,
    BuyerProfile,
    FarmerProfile,
    KycStatus,
    RetailerProfile,
    Role,
    TransportProviderProfile,
    User,
)
from apps.paybill.services.account_number import generate_transport_deposit_account  # noqa: E402


USERS = [
    {
        'phone': '+254724167079',
        'username': 'dante',
        'first_name': 'Dante',
        'role': Role.TRANSPORT_PROVIDER,
    },
    {
        'phone': '+254724167078',
        'username': 'john',
        'first_name': 'John',
        'role': Role.RETAILER,
    },
    {
        'phone': '+254724167077',
        'username': 'ali',
        'first_name': 'Ali',
        'role': Role.FARMER,
    },
    {
        'phone': '+254756379735',
        'username': 'Dant',
        'first_name': 'Dant',
        'role': Role.BUYER,
    },
    {
        'phone': '+254724167076',
        'username': 'admin',
        'email': 'dankarish.DK@gmail.com',
        'first_name': 'Admin',
        'role': Role.BUYER,
        'is_staff': True,
        'is_superuser': True,
    },
]


def ensure_profile(user: User) -> None:
    if user.role == Role.FARMER:
        FarmerProfile.objects.get_or_create(user=user, defaults={'mpesa_number': user.phone})
    elif user.role == Role.RETAILER:
        RetailerProfile.objects.get_or_create(user=user)
    elif user.role == Role.BUYER:
        BuyerProfile.objects.get_or_create(user=user)
    elif user.role == Role.TRANSPORT_PROVIDER:
        TransportProviderProfile.objects.get_or_create(user=user)
        generate_transport_deposit_account(user.transport_profile.id)


def seed(password: str, reset_password: bool) -> None:
    for definition in USERS:
        phone = definition['phone']
        defaults = {
            'username': definition['username'],
            'first_name': definition['first_name'],
            'role': definition['role'],
            'is_active': True,
            'account_status': AccountStatus.PENDING,
            'kyc_status': KycStatus.PENDING,
            'is_phone_verified': True,
        }
        if definition.get('email'):
            defaults['email'] = definition['email']
        if definition.get('is_staff'):
            defaults['is_staff'] = True
            defaults['is_superuser'] = True

        user, created = User.objects.update_or_create(phone=phone, defaults=defaults)
        if created or reset_password or not user.has_usable_password():
            user.set_password(password)
            user.save(update_fields=['password'])
        ensure_profile(user)
        print(f"{'created' if created else 'updated'} {user.phone} | {user.username} | {user.role}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Seed Mambonami development users.')
    parser.add_argument('--reset-password', action='store_true', help='Set the seed password for every seeded user.')
    parser.add_argument('--password', default=os.getenv('SEED_PASSWORD', 'ChangeMe123!'), help='Development password.')
    args = parser.parse_args()
    seed(args.password, args.reset_password)
