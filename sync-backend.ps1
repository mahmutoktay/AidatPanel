# sync-backend.ps1
# This script syncs all backend files to the server, excluding node_modules, uploads, and .env files.

$tempDir = "c:\AidatPanel\backend_sync_temp"

Write-Host "Temizleme yapılıyor..."
if (Test-Path $tempDir) { 
    Remove-Item $tempDir -Recurse -Force 
}

Write-Host "Geçici dizin oluşturuluyor..."
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "Dosyalar kopyalanıyor (node_modules, uploads ve .env* hariç)..."
Copy-Item -Path "c:\AidatPanel\backend\*" -Destination $tempDir -Recurse -Exclude "node_modules", "uploads", ".env*" -Force

Write-Host "Sunucuya yükleniyor..."
scp -i "C:/Users/aaudr/.ssh/aidatpanel_deploy_key" -r "$tempDir\*" aidatpanel-api@62.171.146.132:/home/aidatpanel-api/htdocs/api.aidatpanel.com/

Write-Host "Geçici dizin temizleniyor..."
Remove-Item $tempDir -Recurse -Force

Write-Host "Senkronizasyon tamamlandı!"
