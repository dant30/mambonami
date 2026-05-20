# mobile_file_structure.ps1
# Run this script in the parent directory where you want the 'mobile' folder created.
# It will generate the complete Flutter project scaffold with all directories and placeholder files.

$ErrorActionPreference = "Stop"

$root = "mobile"

Write-Host "Creating Flutter project structure in '$root'..." -ForegroundColor Cyan

# Helper to create directory if not exists
function Ensure-Directory {
    param([string]$path)
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "  Created directory: $path" -ForegroundColor Green
    } else {
        Write-Host "  Directory already exists: $path" -ForegroundColor DarkYellow
    }
}

# Helper to create file with optional content
function Create-File {
    param([string]$path, [string]$content = "")
    $dir = Split-Path $path -Parent
    Ensure-Directory $dir
    if (-not (Test-Path $path)) {
        Set-Content -Path $path -Value $content -Encoding utf8
        Write-Host "  Created file: $path" -ForegroundColor Green
    } else {
        Write-Host "  File already exists (skipped): $path" -ForegroundColor DarkYellow
    }
}

# ============================================
# 1. Create all directories
# ============================================
$directories = @(
    "$root/assets/icons",
    "$root/assets/fonts",
    "$root/assets/translations",
    "$root/lib/core",
    "$root/lib/config",
    "$root/lib/data/models",
    "$root/lib/data/dtos",
    "$root/lib/data/repositories",
    "$root/lib/data/local",
    "$root/lib/blocs/auth",
    "$root/lib/blocs/product",
    "$root/lib/blocs/order",
    "$root/lib/blocs/trip",
    "$root/lib/blocs/notification",
    "$root/lib/blocs/common",
    "$root/lib/features/auth/pages",
    "$root/lib/features/auth/widgets",
    "$root/lib/features/farmer/pages",
    "$root/lib/features/farmer/widgets",
    "$root/lib/features/buyer/pages",
    "$root/lib/features/buyer/widgets",
    "$root/lib/features/transport/pages",
    "$root/lib/features/transport/widgets",
    "$root/lib/features/common",
    "$root/lib/shared/widgets",
    "$root/lib/shared/themes",
    "$root/lib/shared/utils",
    "$root/lib/services",
    "$root/test/core",
    "$root/test/data",
    "$root/test/blocs",
    "$root/test/features",
    "$root/integration_test"
)

foreach ($dir in $directories) {
    Ensure-Directory $dir
}

# ============================================
# 2. Create files with content / placeholders
# ============================================

# --- Root files -------------------------------------------------
Create-File "$root/pubspec.yaml" @"
name: mobile
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  dio: ^5.3.2
  flutter_secure_storage: ^9.0.0
  firebase_messaging: ^14.7.10
  sqflite: ^2.3.0
  hive_flutter: ^1.1.0
  location: ^5.0.0
  camera: ^0.10.5
  image_picker: ^1.0.4
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/translations/
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins.ttf
"@

Create-File "$root/.env.example" @"
# API Configuration
API_BASE_URL=https://api.example.com/v1
# Other environment variables (copy to .env for local development)
"@

# --- Assets (empty placeholder binary files) --------------------
Create-File "$root/assets/icons/logo.png"      # empty binary placeholder
Create-File "$root/assets/icons/farmer_icon.png"
Create-File "$root/assets/icons/buyer_icon.png"
Create-File "$root/assets/icons/transport_icon.png"
Create-File "$root/assets/fonts/Poppins.ttf"   # empty binary placeholder

Create-File "$root/assets/translations/en.json" @'
{
  "app_name": "Mobile App",
  "welcome": "Welcome"
}
'@
Create-File "$root/assets/translations/sw.json" @'
{
  "app_name": "Programu ya Simu",
  "welcome": "Karibu"
}
'@

# --- lib/core files --------------------------------------------
Create-File "$root/lib/core/api_client.dart"   "// Dio wrapper with interceptors"
Create-File "$root/lib/core/constants.dart"    "// API endpoints and app constants"
Create-File "$root/lib/core/secure_storage.dart" "// JWT & user data storage"
Create-File "$root/lib/core/notification_service.dart" "// Firebase push notifications"
Create-File "$root/lib/core/logger.dart"       "// Logging utility"
Create-File "$root/lib/core/utils.dart"        "// Formatting helpers"

# --- lib/config files ------------------------------------------
Create-File "$root/lib/config/app_config.dart" "// Environment variables"
Create-File "$root/lib/config/routes.dart"     "// Named routes"
Create-File "$root/lib/config/theme.dart"      "// Light/dark theme definitions"

# --- lib/data models -------------------------------------------
Create-File "$root/lib/data/models/user.dart"      "class User {}"
Create-File "$root/lib/data/models/product.dart"   "class Product {}"
Create-File "$root/lib/data/models/order.dart"     "class Order {}"
Create-File "$root/lib/data/models/trip.dart"      "class Trip {}"
Create-File "$root/lib/data/models/notification.dart" "class AppNotification {}"

# --- lib/data dtos ---------------------------------------------
Create-File "$root/lib/data/dtos/auth_dto.dart"    "// Auth request/response DTOs"
Create-File "$root/lib/data/dtos/order_dto.dart"   "// Order DTOs"

# --- lib/data repositories -------------------------------------
Create-File "$root/lib/data/repositories/auth_repository.dart"
Create-File "$root/lib/data/repositories/product_repository.dart"
Create-File "$root/lib/data/repositories/order_repository.dart"
Create-File "$root/lib/data/repositories/trip_repository.dart"
Create-File "$root/lib/data/repositories/notification_repository.dart"

# --- lib/data local --------------------------------------------
Create-File "$root/lib/data/local/database_helper.dart"
Create-File "$root/lib/data/local/cache_manager.dart"

# --- lib/blocs (event/state/bloc stubs) ------------------------
function Create-BlocStubs {
    param($name, $path)
    Create-File "$path/${name}_bloc.dart"    "import 'package:flutter_bloc/flutter_bloc.dart';"
    Create-File "$path/${name}_event.dart"   "abstract class ${name}Event {}"
    Create-File "$path/${name}_state.dart"   "abstract class ${name}State {}"
}

Create-BlocStubs "auth"   "$root/lib/blocs/auth"
Create-BlocStubs "product" "$root/lib/blocs/product"
Create-BlocStubs "order"   "$root/lib/blocs/order"
Create-BlocStubs "trip"    "$root/lib/blocs/trip"
Create-BlocStubs "notification" "$root/lib/blocs/notification"
Create-BlocStubs "connectivity" "$root/lib/blocs/common"
Create-BlocStubs "theme"       "$root/lib/blocs/common"

# --- lib/features/auth -----------------------------------------
Create-File "$root/lib/features/auth/pages/login_page.dart" "// Login screen"
Create-File "$root/lib/features/auth/pages/register_init_page.dart" "// Phone + role"
Create-File "$root/lib/features/auth/pages/register_verify_page.dart" "// OTP + details"
Create-File "$root/lib/features/auth/pages/forgot_password_page.dart" "// Forgot password"
Create-File "$root/lib/features/auth/widgets/phone_input_field.dart"
Create-File "$root/lib/features/auth/widgets/otp_input_field.dart"
Create-File "$root/lib/features/auth/auth_guard.dart" "// Role-based redirect"

# --- lib/features/farmer ---------------------------------------
$farmerPages = @("farmer_dashboard","product_list_page","product_create_page","product_edit_page","order_requests_page","order_detail_page","earnings_page")
foreach ($page in $farmerPages) {
    Create-File "$root/lib/features/farmer/pages/$page.dart" "// Farmer $page"
}
Create-File "$root/lib/features/farmer/widgets/product_card.dart"
Create-File "$root/lib/features/farmer/widgets/order_request_card.dart"
Create-File "$root/lib/features/farmer/widgets/earnings_summary.dart"

# --- lib/features/buyer ----------------------------------------
$buyerPages = @("buyer_dashboard","product_catalog_page","product_detail_page","cart_page","checkout_page","order_history_page","order_tracking_page","dispute_page")
foreach ($page in $buyerPages) {
    Create-File "$root/lib/features/buyer/pages/$page.dart" "// Buyer $page"
}
Create-File "$root/lib/features/buyer/widgets/product_grid_tile.dart"
Create-File "$root/lib/features/buyer/widgets/cart_item.dart"
Create-File "$root/lib/features/buyer/widgets/order_status_timeline.dart"
Create-File "$root/lib/features/buyer/widgets/otp_verification_dialog.dart"

# --- lib/features/transport ------------------------------------
$transportPages = @("provider_dashboard","available_orders_page","my_trips_page","trip_detail_page","pickup_page","delivery_page","earnings_page")
foreach ($page in $transportPages) {
    Create-File "$root/lib/features/transport/pages/$page.dart" "// Transport $page"
}
Create-File "$root/lib/features/transport/widgets/order_offer_card.dart"
Create-File "$root/lib/features/transport/widgets/trip_card.dart"
Create-File "$root/lib/features/transport/widgets/photo_capture_widget.dart"

# --- lib/features/common ---------------------------------------
$commonPages = @("profile_page","settings_page","notifications_page","support_page")
foreach ($page in $commonPages) {
    Create-File "$root/lib/features/common/$page.dart" "// $page"
}

# --- lib/shared ------------------------------------------------
$sharedWidgets = @("custom_app_bar","loading_indicator","error_widget","empty_state","bottom_nav_bar","custom_button","custom_text_field","role_guard_builder")
foreach ($w in $sharedWidgets) {
    Create-File "$root/lib/shared/widgets/${w}.dart" "// $w widget"
}
Create-File "$root/lib/shared/themes/light_theme.dart" "// Light theme"
Create-File "$root/lib/shared/themes/dark_theme.dart"  "// Dark theme"
Create-File "$root/lib/shared/utils/form_validators.dart"
Create-File "$root/lib/shared/utils/image_picker_helper.dart"
Create-File "$root/lib/shared/utils/permission_handler.dart"

# --- lib/services ----------------------------------------------
Create-File "$root/lib/services/location_service.dart" "// GPS service"
Create-File "$root/lib/services/camera_service.dart"   "// Camera helper"
Create-File "$root/lib/services/payment_helper.dart"    "// M-Pesa deep link"

# --- lib/main.dart --------------------------------------------
Create-File "$root/lib/main.dart" @"
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(body: Center(child: Text('Hello World'))),
    );
  }
}
"@

# --- Test directories placeholder files ------------------------
Create-File "$root/test/core/core_test.dart" "// Core tests"
Create-File "$root/test/data/data_test.dart" "// Data layer tests"
Create-File "$root/test/blocs/blocs_test.dart" "// Bloc tests"
Create-File "$root/test/features/features_test.dart" "// Feature tests"
Create-File "$root/integration_test/app_test.dart" "// Integration tests"

Write-Host "`n✅ Project structure created successfully in '$root'." -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. cd $root" -ForegroundColor White
Write-Host "2. Run 'flutter pub get' to fetch dependencies" -ForegroundColor White
Write-Host "3. Add your actual assets (icons, fonts) and environment variables" -ForegroundColor White