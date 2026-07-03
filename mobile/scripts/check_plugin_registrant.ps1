# PluginRegistrant.kt vs .flutter-plugins-dependencies (Android)
# Usage: cd mobile; .\scripts\check_plugin_registrant.ps1

$ErrorActionPreference = "Stop"
$mobileRoot = Split-Path $PSScriptRoot -Parent
$depsFile = Join-Path $mobileRoot ".flutter-plugins-dependencies"
$registrantFile = Join-Path $mobileRoot "android\app\src\main\kotlin\com\aidatpanel\app\PluginRegistrant.kt"

if (-not (Test-Path $depsFile)) { Write-Error "Run: flutter pub get" }
if (-not (Test-Path $registrantFile)) { Write-Error "PluginRegistrant.kt not found" }

$json = Get-Content $depsFile -Raw | ConvertFrom-Json
$androidPlugins = @($json.plugins.android | ForEach-Object { $_.name })
$text = Get-Content $registrantFile -Raw

# pub name -> PluginRegistrant.kt içinde aranacak alt dize
$symbolByPlugin = @{
    "device_info_plus"              = "device_info.DeviceInfoPlusPlugin"
    "file_picker"                   = "FilePickerPlugin"
    "firebase_analytics"            = "firebase.analytics.FlutterFirebaseAnalyticsPlugin"
    "firebase_core"                 = "FlutterFirebaseCorePlugin"
    "firebase_crashlytics"          = "firebase.crashlytics.FlutterFirebaseCrashlyticsPlugin"
    "firebase_messaging"            = "FlutterFirebaseMessagingPlugin"
    "flutter_local_notifications"   = "FlutterLocalNotificationsPlugin"
    "flutter_plugin_android_lifecycle" = "FlutterAndroidLifecyclePlugin"
    "flutter_secure_storage"        = "FlutterSecureStoragePlugin"
    "gal"                           = "gal.GalPlugin"
    "image_picker_android"          = "ImagePickerPlugin"
    "jni"                           = "JniPlugin"
    "jni_flutter"                   = "JniFlutterPlugin"
    "package_info_plus"             = "packageinfo.PackageInfoPlugin"
    "path_provider_android"         = "JniFlutterPlugin"
    "pdfx"                          = "PdfxPlugin"
    "permission_handler_android"      = "PermissionHandlerPlugin"
    "purchases_flutter"             = "PurchasesFlutterPlugin"
    "receive_sharing_intent"        = "ReceiveSharingIntentPlugin"
    "share_plus"                    = "share.SharePlusPlugin"
    "sqflite_android"               = "sqflite.SqflitePlugin"
}

$failed = @()
foreach ($pluginName in $androidPlugins) {
    if ($pluginName -eq "integration_test") { continue }
    $symbol = $symbolByPlugin[$pluginName]
    if (-not $symbol) {
        Write-Host "WARN: No symbol mapping for plugin '$pluginName' - update check_plugin_registrant.ps1" -ForegroundColor Yellow
        continue
    }
    if ($text -notmatch [regex]::Escape($symbol)) {
        $failed += "$pluginName -> $symbol"
    }
}

Write-Host "Android plugins from pub: $($androidPlugins -join ', ')"
if ($failed.Count -gt 0) {
    Write-Host "MISSING in PluginRegistrant.kt:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  $_" }
    exit 1
}
Write-Host "PluginRegistrant check OK." -ForegroundColor Green
exit 0
