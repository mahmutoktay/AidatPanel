# AidatPanel backend — VPS deploy (Mutagen yerine SSH + tar)
# Kullanım:
#   .\backend\scripts\deploy.ps1              # yükle + npm + migrate + restart
#   .\backend\scripts\deploy.ps1 -SyncOnly    # sadece dosya yükle
#   .\backend\scripts\deploy.ps1 -RestartOnly # sadece pm2 restart
#   .\backend\scripts\deploy.ps1 -Logs        # son log satırları
#
# İlk kurulum: deploy.config.example.json → deploy.local.json kopyalayın (gitignore'da)

param(
    [switch]$RestartOnly,
    [switch]$SyncOnly,
    [switch]$Logs,
    [int]$LogLines = 80
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $ScriptDir "deploy.local.json"
$ExamplePath = Join-Path $ScriptDir "deploy.config.example.json"
$BackendRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path

if (-not (Test-Path $ConfigPath)) {
    Write-Host ""
    Write-Host "HATA: deploy.local.json bulunamadi." -ForegroundColor Red
    Write-Host "  1. Copy-Item '$ExamplePath' '$ConfigPath'"
    Write-Host "  2. Sunucu bilgilerini duzenleyin (host, user, remotePath, sshKeyPath)"
    Write-Host "  3. SSH anahtar ile giris testi: ssh -i KEY user@host"
    Write-Host ""
    exit 1
}

$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

foreach ($key in @("host", "user", "remotePath")) {
    if (-not $config.$key) {
        Write-Error "deploy.local.json icinde '$key' eksik."
    }
}

$port = if ($config.port) { [int]$config.port } else { 22 }
$method = if ($config.method) { $config.method } else { "sync" }
$restartMethod = if ($config.restartMethod) { $config.restartMethod } else { "pm2" }
$pm2Name = if ($config.pm2Name) { $config.pm2Name } else { "aidapanel-api" }
$healthUrl = $config.healthUrl
$sshTarget = "$($config.user)@$($config.host)"

function Get-SshBaseArgs {
    $args = @()
    if ($config.sshKeyPath) {
        $key = $config.sshKeyPath -replace '\\', '/'
        if (-not (Test-Path $config.sshKeyPath)) {
            Write-Error "SSH anahtari bulunamadi: $($config.sshKeyPath)"
        }
        $args += @("-i", $config.sshKeyPath)
    }
    if ($port -ne 22) { $args += @("-p", "$port") }
    $args += @("-o", "BatchMode=yes", "-o", "StrictHostKeyChecking=accept-new")
    return $args
}

function Invoke-Ssh {
    param([string]$RemoteCommand)
    # Windows CRLF bash'i bozar — LF'e cevir.
    $RemoteCommand = ($RemoteCommand -replace "`r`n", "`n") -replace "`r", ""
    $base = Get-SshBaseArgs
    & ssh @base $sshTarget $RemoteCommand
    if ($LASTEXITCODE -ne 0) {
        throw "SSH komutu basarisiz (exit $LASTEXITCODE): $RemoteCommand"
    }
}

function Invoke-Scp {
    param([string]$LocalPath, [string]$RemoteDest)
    $base = Get-SshBaseArgs
    & scp @base $LocalPath "${sshTarget}:$RemoteDest"
    if ($LASTEXITCODE -ne 0) {
        throw "SCP basarisiz: $LocalPath -> $RemoteDest"
    }
}

function Sync-BackendGit {
    Write-Host ">> Git deploy: uzak repodan cekiliyor..." -ForegroundColor Cyan
    $parent = ($config.remotePath -replace '/backend$', '')
    if (-not $parent -or $parent -eq $config.remotePath) {
        $parent = Split-Path $config.remotePath -Parent
    }
    $branch = if ($config.gitBranch) { $config.gitBranch } else { "main" }
    Invoke-Ssh "cd '$parent' && git fetch origin && git checkout $branch && git pull origin $branch"
}

function Sync-BackendTar {
    Write-Host ">> Sync deploy: backend/ -> $($config.remotePath)" -ForegroundColor Cyan

    $tarFile = Join-Path $env:TEMP "aidatpanel-backend-$(Get-Date -Format 'yyyyMMddHHmmss').tar.gz"
    $remoteTar = "/tmp/aidatpanel-backend-deploy.tar.gz"

    Push-Location $BackendRoot
    try {
        if (-not (Get-Command tar -ErrorAction SilentlyContinue)) {
            throw "Windows 'tar' bulunamadi. Windows 10+ gerekli veya WSL kullanin."
        }

        & tar -czf $tarFile `
            --exclude=node_modules `
            --exclude=.env `
            --exclude=.env.* `
            --exclude=uploads/dekonts/* `
            --exclude='*-firebase-adminsdk-*.json' `
            --exclude=scripts/deploy.local.json `
            --exclude=e2e-data `
            --exclude=coverage `
            --exclude=*.log `
            .

        if ($LASTEXITCODE -ne 0) {
            throw "tar olusturma basarisiz"
        }

        Write-Host "   arsiv: $([math]::Round((Get-Item $tarFile).Length / 1KB)) KB" -ForegroundColor DarkGray
        Invoke-Scp $tarFile $remoteTar
        Invoke-Ssh "mkdir -p '$($config.remotePath)' && cd '$($config.remotePath)' && tar -xzf '$remoteTar' && rm -f '$remoteTar'"
    }
    finally {
        Pop-Location
        if (Test-Path $tarFile) { Remove-Item $tarFile -Force }
    }
}

function Invoke-RemoteDeploy {
    Write-Host ">> Sunucuda npm + prisma + restart ($restartMethod)..." -ForegroundColor Cyan

    if ($restartMethod -eq "pm2") {
        $pm2Name = if ($config.pm2Name) { $config.pm2Name } else { "aidapanel-api" }
        $cmd = @"
set -e
source ~/.nvm/nvm.sh
cd '$($config.remotePath)'
npm ci --omit=dev
npx prisma migrate deploy
npx prisma generate
if pm2 describe '$pm2Name' >/dev/null 2>&1; then
  pm2 restart '$pm2Name'
else
  pm2 start index.js --name '$pm2Name'
fi
pm2 save
"@
    }
    else {
        $cmd = @"
set -e
source ~/.nvm/nvm.sh
cd '$($config.remotePath)'
npm ci --omit=dev
npx prisma migrate deploy
npx prisma generate
pkill -u "`$(whoami)" -f '$($config.remotePath)/index.js' 2>/dev/null || true
sleep 2
mkdir -p logs
nohup node index.js >> logs/app.log 2>&1 &
sleep 2
pgrep -af '$($config.remotePath)/index.js' || (echo 'Node baslatilamadi' && exit 1)
"@
    }
    Invoke-Ssh $cmd
}

function Test-Health {
    if ($healthUrl) {
        Write-Host ">> Saglik kontrolu: $healthUrl" -ForegroundColor Cyan
        try {
            $resp = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 15
            Write-Host "   HTTP $($resp.StatusCode)" -ForegroundColor Green
        }
        catch {
            Write-Host "   UYARI: health endpoint yanit vermedi." -ForegroundColor Yellow
        }
        return
    }
    if ($restartMethod -eq "pm2") {
    Write-Host ">> Process kontrolu (pm2)..." -ForegroundColor Cyan
        Invoke-Ssh "source ~/.nvm/nvm.sh && pm2 describe '$pm2Name' | head -10"
        return
    }
    Write-Host ">> Process kontrolu..." -ForegroundColor Cyan
    Invoke-Ssh "pgrep -af '$($config.remotePath)/index.js' | head -3"
}

Write-Host ""
Write-Host "AidatPanel Backend Deploy" -ForegroundColor White
Write-Host "  hedef: $sshTarget`:$($config.remotePath)" -ForegroundColor DarkGray
Write-Host ""

if ($Logs) {
    if ($restartMethod -eq "pm2") {
        Invoke-Ssh "source ~/.nvm/nvm.sh && pm2 logs '$pm2Name' --lines $LogLines --nostream"
    }
    else {
        Invoke-Ssh "tail -n $LogLines '$($config.remotePath)/logs/app.log' 2>/dev/null || echo 'log dosyasi henuz yok'"
    }
    exit 0
}

if (-not $RestartOnly) {
    if ($method -eq "git") {
        Sync-BackendGit
    }
    else {
        Sync-BackendTar
    }
}

if (-not $SyncOnly) {
    if ($RestartOnly -and $restartMethod -eq "pm2") {
        Write-Host ">> PM2 restart: $pm2Name" -ForegroundColor Cyan
        Invoke-Ssh "source ~/.nvm/nvm.sh && pm2 restart '$pm2Name'"
    }
    else {
        Invoke-RemoteDeploy
    }
    Test-Health
    Write-Host ""
    Write-Host "Deploy tamam." -ForegroundColor Green
    Write-Host "  Log: .\backend\scripts\deploy.ps1 -Logs" -ForegroundColor DarkGray
}
else {
    Write-Host ""
    Write-Host "Sync tamam (restart atlanmadi)." -ForegroundColor Green
}

Write-Host ""
