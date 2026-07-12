# backend/django_admin/apps/notifications/models/notification.py
from django.conf import settings
from django.db import models
from django.template import Context, Template
from django.utils import timezone

from shared.db_models.base import BaseModel


# ============================================================================
# NOTIFICATION
# ============================================================================

class Notification(BaseModel):

    class Channel(models.TextChoices):
        PUSH = "push", "Push Notification"
        IN_APP = "in_app", "In-App"
        EMAIL = "email", "Email"
        SMS = "sms", "SMS"
        WHATSAPP = "whatsapp", "WhatsApp"

    class Category(models.TextChoices):
        PAYMENT = "payment", "Payment / Escrow"
        ORDER = "order", "Order Update"
        DELIVERY = "delivery", "Delivery Update"
        REVIEW = "review", "Review"
        DISPUTE = "dispute", "Dispute"
        VERIFICATION = "verification", "Verification"
        PRICE_ALERT = "price_alert", "Price / Market Alert"
        PROMOTION = "promotion", "Promotion"
        SYSTEM = "system", "System"

    class DeliveryStatus(models.TextChoices):
        PENDING = "pending", "Pending"
        QUEUED = "queued", "Queued"
        SENT = "sent", "Sent"
        FAILED = "failed", "Failed"

    class Priority(models.TextChoices):
        LOW = "low", "Low"
        NORMAL = "normal", "Normal"
        HIGH = "high", "High"
        CRITICAL = "critical", "Critical"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="notifications",
    )

    channel = models.CharField(
        max_length=20,
        choices=Channel.choices,
        db_index=True,
    )

    category = models.CharField(
        max_length=30,
        choices=Category.choices,
        default=Category.SYSTEM,
        db_index=True,
    )

    priority = models.CharField(
        max_length=10,
        choices=Priority.choices,
        default=Priority.NORMAL,
        db_index=True,
    )

    title = models.CharField(max_length=200)

    body = models.TextField()

    metadata = models.JSONField(
        default=dict,
        blank=True,
        help_text="Extra information (order_id, wallet_id, dispute_id etc.)",
    )

    delivery_status = models.CharField(
        max_length=20,
        choices=DeliveryStatus.choices,
        default=DeliveryStatus.PENDING,
        db_index=True,
    )

    is_read = models.BooleanField(default=False)

    action_url = models.CharField(
        max_length=255,
        blank=True,
        help_text="Deep link e.g. mambonami://orders/123",
    )

    image = models.URLField(
        blank=True,
        help_text="Optional image/banner shown with notification",
    )

    external_id = models.CharField(
        max_length=120,
        blank=True,
        help_text="FCM/Twilio/SendGrid message id",
    )

    error_message = models.TextField(blank=True)

    delivered_at = models.DateTimeField(
        blank=True,
        null=True,
    )

    read_at = models.DateTimeField(
        blank=True,
        null=True,
    )

    expires_at = models.DateTimeField(
        blank=True,
        null=True,
    )

    class Meta:
        db_table = "notifications"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["user", "delivery_status"]),
            models.Index(fields=["user", "is_read"]),
            models.Index(fields=["category"]),
            models.Index(fields=["priority"]),
            models.Index(fields=["created_at"]),
        ]

    def __str__(self):
        return f"{self.user.phone} - {self.title}"

    def mark_as_read(self):
        if not self.is_read:
            self.is_read = True
            self.read_at = timezone.now()
            self.save(update_fields=["is_read", "read_at"])

    @property
    def status(self):
        return self.delivery_status

    @status.setter
    def status(self, value):
        self.delivery_status = value

    @property
    def notification_type(self):
        return self.category

    @notification_type.setter
    def notification_type(self, value):
        self.category = value

    @property
    def type(self):
        return self.category

    @type.setter
    def type(self, value):
        self.category = value

    def get_notification_type_display(self):
        return self.get_category_display()


# ============================================================================
# USER PREFERENCES
# ============================================================================

class NotificationPreference(BaseModel):

    class Category(models.TextChoices):
        ORDER = "order", "Order Updates"
        DELIVERY = "delivery", "Delivery Updates"
        PAYMENT = "payment", "Payments"
        DISPUTE = "dispute", "Disputes"
        REVIEW = "review", "Reviews"
        PROMOTION = "promotion", "Promotions"
        VERIFICATION = "verification", "Verification"
        SYSTEM = "system", "System"

    class Channel(models.TextChoices):
        PUSH = "push", "Push"
        EMAIL = "email", "Email"
        SMS = "sms", "SMS"
        WHATSAPP = "whatsapp", "WhatsApp"
        IN_APP = "in_app", "In-App"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="notification_preferences",
    )

    category = models.CharField(
        max_length=30,
        choices=Category.choices,
    )

    channel = models.CharField(
        max_length=20,
        choices=Channel.choices,
    )

    enabled = models.BooleanField(default=True)

    quiet_hours_start = models.TimeField(
        null=True,
        blank=True,
    )

    quiet_hours_end = models.TimeField(
        null=True,
        blank=True,
    )

    language = models.CharField(
        max_length=10,
        default="en",
    )

    class Meta:
        db_table = "notification_preferences"
        unique_together = (
            "user",
            "category",
            "channel",
        )

    def __str__(self):
        return f"{self.user.phone} - {self.category}"


# ============================================================================
# DEVICE TOKENS
# ============================================================================

class NotificationDevice(BaseModel):

    class Platform(models.TextChoices):
        ANDROID = "android", "Android"
        IOS = "ios", "iOS"
        WEB = "web", "Web"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="notification_devices",
    )

    token = models.CharField(
        max_length=500,
        unique=True,
    )

    platform = models.CharField(
        max_length=20,
        choices=Platform.choices,
    )

    device_name = models.CharField(
        max_length=120,
        blank=True,
    )

    app_version = models.CharField(
        max_length=50,
        blank=True,
    )

    is_active = models.BooleanField(default=True)

    last_seen = models.DateTimeField(
        auto_now=True,
    )

    class Meta:
        db_table = "notification_devices"

    def __str__(self):
        return f"{self.user.phone} ({self.platform})"


# ============================================================================
# MESSAGE TEMPLATES
# ============================================================================

class NotificationTemplate(BaseModel):

    class Channel(models.TextChoices):
        PUSH = "push", "Push"
        EMAIL = "email", "Email"
        SMS = "sms", "SMS"
        WHATSAPP = "whatsapp", "WhatsApp"
        IN_APP = "in_app", "In-App"

    name = models.CharField(
        max_length=100,
        unique=True,
    )

    channel = models.CharField(
        max_length=20,
        choices=Channel.choices,
    )

    subject = models.CharField(
        max_length=200,
        blank=True,
    )

    body_template = models.TextField()

    variables = models.JSONField(
        default=list,
        blank=True,
        help_text="Expected placeholders",
    )

    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = "notification_templates"

    def __str__(self):
        return self.name

    def render(self, context: dict):
        template = Template(self.body_template)
        return template.render(Context(context))


# ============================================================================
# BROADCAST CAMPAIGNS
# ============================================================================

class NotificationCampaign(BaseModel):

    class Status(models.TextChoices):
        DRAFT = "draft", "Draft"
        SCHEDULED = "scheduled", "Scheduled"
        RUNNING = "running", "Running"
        COMPLETED = "completed", "Completed"
        CANCELLED = "cancelled", "Cancelled"

    title = models.CharField(
        max_length=200,
    )

    body = models.TextField()

    audience = models.CharField(
        max_length=100,
        help_text="buyers, farmers, riders, admins, all, custom",
    )

    scheduled_at = models.DateTimeField(
        null=True,
        blank=True,
    )

    sent_at = models.DateTimeField(
        null=True,
        blank=True,
    )

    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.DRAFT,
    )

    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name="created_notification_campaigns",
    )

    class Meta:
        db_table = "notification_campaigns"

    def __str__(self):
        return self.title


# ============================================================================
# PROVIDER LOGS
# ============================================================================

class NotificationLog(BaseModel):

    notification = models.ForeignKey(
        Notification,
        on_delete=models.CASCADE,
        related_name="logs",
    )

    provider = models.CharField(
        max_length=50,
    )

    status = models.CharField(
        max_length=50,
    )

    response = models.JSONField(
        default=dict,
        blank=True,
    )

    class Meta:
        db_table = "notification_logs"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.provider} - {self.status}"