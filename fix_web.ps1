# fix_web.ps1
# Fix files created by web.ps1 with improper line breaks

$webRoot = ".\web"

function Fix-File($relativePath, $content) {
    $fullPath = Join-Path $webRoot $relativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Set-Content -Path $fullPath -Value $content -Encoding utf8
    Write-Host "Fixed: $fullPath" -ForegroundColor Yellow
}

# Fix auth pages
Fix-File "src\features\auth\pages\Login.tsx" @"
import React from 'react';
export default function Login() { 
  return <div>Login Page</div>; 
}
"@

Fix-File "src\features\auth\pages\Register.tsx" @"
export default function Register() { 
  return <div>Register Page</div>; 
}
"@

Fix-File "src\features\auth\pages\ForgotPassword.tsx" @"
export default function ForgotPassword() { 
  return <div>Forgot Password</div>; 
}
"@

Fix-File "src\features\auth\pages\Profile.tsx" @"
export default function Profile() { 
  return <div>Profile</div>; 
}
"@

# Fix orders pages
Fix-File "src\features\orders\pages\OrderList.tsx" @"
export default function OrderList() { 
  return <div>OrderList</div>; 
}
"@

Fix-File "src\features\orders\pages\OrderDetail.tsx" @"
export default function OrderDetail() { 
  return <div>OrderDetail</div>; 
}
"@

Fix-File "src\features\orders\pages\CreateOrder.tsx" @"
export default function CreateOrder() { 
  return <div>CreateOrder</div>; 
}
"@

# Fix products pages
Fix-File "src\features\products\pages\ProductList.tsx" @"
export default function ProductList() { 
  return <div>ProductList</div>; 
}
"@

Fix-File "src\features\products\pages\ProductDetail.tsx" @"
export default function ProductDetail() { 
  return <div>ProductDetail</div>; 
}
"@

Fix-File "src\features\products\pages\ProductCreate.tsx" @"
export default function ProductCreate() { 
  return <div>ProductCreate</div>; 
}
"@

Fix-File "src\features\products\pages\ProductEdit.tsx" @"
export default function ProductEdit() { 
  return <div>ProductEdit</div>; 
}
"@

# Fix transport pages
Fix-File "src\features\transport\pages\ProviderList.tsx" @"
export default function ProviderList() { 
  return <div>ProviderList</div>; 
}
"@

Fix-File "src\features\transport\pages\ProviderDetail.tsx" @"
export default function ProviderDetail() { 
  return <div>ProviderDetail</div>; 
}
"@

Fix-File "src\features\transport\pages\ProviderApproval.tsx" @"
export default function ProviderApproval() { 
  return <div>ProviderApproval</div>; 
}
"@

Fix-File "src\features\transport\pages\ProviderTrips.tsx" @"
export default function ProviderTrips() { 
  return <div>ProviderTrips</div>; 
}
"@

# Fix disputes pages
Fix-File "src\features\disputes\pages\DisputeList.tsx" @"
export default function DisputeList() { 
  return <div>DisputeList</div>; 
}
"@

Fix-File "src\features\disputes\pages\DisputeDetail.tsx" @"
export default function DisputeDetail() { 
  return <div>DisputeDetail</div>; 
}
"@

Fix-File "src\features\disputes\pages\DisputeResolution.tsx" @"
export default function DisputeResolution() { 
  return <div>DisputeResolution</div>; 
}
"@

# Fix payouts pages
Fix-File "src\features\payouts\pages\PayoutList.tsx" @"
export default function PayoutList() { 
  return <div>PayoutList</div>; 
}
"@

Fix-File "src\features\payouts\pages\PayoutDetail.tsx" @"
export default function PayoutDetail() { 
  return <div>PayoutDetail</div>; 
}
"@

# Fix admin pages
Fix-File "src\features\admin\pages\FarmerApproval.tsx" @"
export default function FarmerApproval() { 
  return <div>FarmerApproval</div>; 
}
"@

Fix-File "src\features\admin\pages\DisputeResolution.tsx" @"
export default function DisputeResolution() { 
  return <div>DisputeResolution</div>; 
}
"@

Fix-File "src\features\admin\pages\AuditLog.tsx" @"
export default function AuditLog() { 
  return <div>AuditLog</div>; 
}
"@

Fix-File "src\features\admin\pages\NotificationsList.tsx" @"
export default function NotificationsList() { 
  return <div>NotificationsList</div>; 
}
"@

Fix-File "src\features\admin\pages\UserManagement.tsx" @"
export default function UserManagement() { 
  return <div>UserManagement</div>; 
}
"@

Fix-File "src\features\admin\pages\Settings.tsx" @"
export default function Settings() { 
  return <div>Settings</div>; 
}
"@

# Fix retailer pages
Fix-File "src\features\retailer\pages\RetailerDashboard.tsx" @"
export default function RetailerDashboard() { 
  return <div>RetailerDashboard</div>; 
}
"@

Fix-File "src\features\retailer\pages\BulkOrder.tsx" @"
export default function BulkOrder() { 
  return <div>BulkOrder</div>; 
}
"@

Fix-File "src\features\retailer\pages\InvoiceList.tsx" @"
export default function InvoiceList() { 
  return <div>InvoiceList</div>; 
}
"@

# Fix not-found page
Fix-File "src\features\not-found\NotFound.tsx" @"
export default function NotFound() { 
  return <div>404 - Page Not Found</div>; 
}
"@

# Fix UI components
$uiComponents = @(
    "Button", "Card", "Input", "Modal", "Dropdown",
    "Chevron", "Spinner", "Tabs", "Tooltip", "Avatar",
    "Badge", "Alert", "ProgressBar", "Loader", "Toast",
    "Switch", "Checkbox", "Radio", "Select", "Textarea",
    "DatePicker", "TimePicker", "FileUpload", "ImageUpload",
    "Pagination", "Skeleton"
)

foreach ($comp in $uiComponents) {
    Fix-File "src\shared\components\ui\${comp}.tsx" @"
import React from 'react';

export const ${comp}: React.FC<{ children?: React.ReactNode }> = ({ children }) => {
  return <div className="${comp}">{children}</div>;
};
"@
}

Write-Host "`n✅ Web files fixed successfully!" -ForegroundColor Green
