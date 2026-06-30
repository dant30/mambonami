# mambonami/shared/enums.py

from django.db import models


class OrderStatus(models.TextChoices):
    CART = 'cart', 'Cart'
    PLACED = 'placed', 'Placed (pending payment)'
    PAID_ESCROW = 'paid_escrow', 'Paid (Escrow held)'
    TRANSPORT_ASSIGNED = 'transport_assigned', 'Transport Assigned'
    PICKED_UP = 'picked_up', 'Picked Up'
    DELIVERED = 'delivered', 'Delivered'
    CANCELLED = 'cancelled', 'Cancelled'
    DISPUTED = 'disputed', 'Disputed'


class VehicleType(models.TextChoices):
    MOTORCYCLE = 'motorcycle', 'Motorcycle'
    PICKUP = 'pickup', 'Pickup'
    VAN = 'van', 'Van'
    LORRY = 'lorry', 'Lorry'


class NotificationChannel(models.TextChoices):
    IN_APP = 'in_app', 'In App'
    SMS = 'sms', 'SMS'
    EMAIL = 'email', 'Email'
