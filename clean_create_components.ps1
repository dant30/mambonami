# clean_create_components.ps1
# Recreate component files with proper formatting

$webRoot = ".\web"

# Helper to create a simple React component
function Create-Component {
    param(
        [string]$Path,
        [string]$ComponentName
    )
    
    $fullPath = Join-Path $webRoot $Path
    $dir = Split-Path $fullPath -Parent
    
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    $content = @"
export default function $ComponentName() {
  return <div>$ComponentName</div>;
}
"@
    
    Set-Content -Path $fullPath -Value $content -Encoding UTF8 -NoNewline
    Add-Content -Path $fullPath -Value "`n" -Encoding UTF8
    Write-Host "Created: $fullPath"
}

# Auth pages
Create-Component "src\features\auth\pages\ForgotPassword.tsx" "ForgotPassword"
Create-Component "src\features\auth\pages\Profile.tsx" "Profile"

# Orders pages
Create-Component "src\features\orders\pages\OrderList.tsx" "OrderList"
Create-Component "src\features\orders\pages\OrderDetail.tsx" "OrderDetail"
Create-Component "src\features\orders\pages\CreateOrder.tsx" "CreateOrder"

# Products pages
Create-Component "src\features\products\pages\ProductList.tsx" "ProductList"
Create-Component "src\features\products\pages\ProductDetail.tsx" "ProductDetail"
Create-Component "src\features\products\pages\ProductCreate.tsx" "ProductCreate"
Create-Component "src\features\products\pages\ProductEdit.tsx" "ProductEdit"

# Transport pages
Create-Component "src\features\transport\pages\ProviderList.tsx" "ProviderList"
Create-Component "src\features\transport\pages\ProviderDetail.tsx" "ProviderDetail"
Create-Component "src\features\transport\pages\ProviderApproval.tsx" "ProviderApproval"
Create-Component "src\features\transport\pages\ProviderTrips.tsx" "ProviderTrips"

# Disputes pages
Create-Component "src\features\disputes\pages\DisputeList.tsx" "DisputeList"
Create-Component "src\features\disputes\pages\DisputeDetail.tsx" "DisputeDetail"
Create-Component "src\features\disputes\pages\DisputeResolution.tsx" "DisputeResolution"

# Payouts pages
Create-Component "src\features\payouts\pages\PayoutList.tsx" "PayoutList"
Create-Component "src\features\payouts\pages\PayoutDetail.tsx" "PayoutDetail"

# Admin pages
Create-Component "src\features\admin\pages\FarmerApproval.tsx" "FarmerApproval"
Create-Component "src\features\admin\pages\DisputeResolution.tsx" "DisputeResolution"
Create-Component "src\features\admin\pages\AuditLog.tsx" "AuditLog"
Create-Component "src\features\admin\pages\NotificationsList.tsx" "NotificationsList"
Create-Component "src\features\admin\pages\UserManagement.tsx" "UserManagement"
Create-Component "src\features\admin\pages\Settings.tsx" "Settings"

# Retailer pages
Create-Component "src\features\retailer\pages\RetailerDashboard.tsx" "RetailerDashboard"
Create-Component "src\features\retailer\pages\BulkOrder.tsx" "BulkOrder"
Create-Component "src\features\retailer\pages\InvoiceList.tsx" "InvoiceList"

# Not-found
Create-Component "src\features\not-found\NotFound.tsx" "NotFound"

# UI Components
$uiComponents = @(
    "Button", "Card", "Input", "Modal", "Dropdown",
    "Chevron", "Spinner", "Tabs", "Tooltip", "Avatar",
    "Badge", "Alert", "ProgressBar", "Loader", "Toast",
    "Switch", "Checkbox", "Radio", "Select", "Textarea",
    "DatePicker", "TimePicker", "FileUpload", "ImageUpload",
    "Pagination", "Skeleton"
)

foreach ($comp in $uiComponents) {
    Create-Component "src\shared\components\ui\${comp}.tsx" "$comp"
}

Write-Host "`nAll components created successfully!"
