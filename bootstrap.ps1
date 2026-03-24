#Requires -Version 5.1
# Dotfiles Bootstrap for Windows
# One-liner: iwr https://raw.githubusercontent.com/mikkel-mouridsen/dotfiles/main/bootstrap.ps1 | iex
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$DOTFILES_REPO = "https://github.com/mikkel-mouridsen/dotfiles.git"
$DOTFILES_DIR = if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { "$HOME\.dotfiles" }

function Log($msg) { Write-Host "==> $msg" -ForegroundColor Blue }
function Ok($msg) { Write-Host " + $msg" -ForegroundColor Green }
function Fail($msg) { Write-Host " x $msg" -ForegroundColor Red; exit 1 }

# -- 0. Check Developer Mode (needed for symlinks without admin) --
$devMode = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
if ($devMode -ne 1) {
    Write-Host ""
    Write-Host "  WARNING: Developer Mode is not enabled." -ForegroundColor Yellow
    Write-Host "  Symlinks may require running as Administrator." -ForegroundColor Yellow
    Write-Host "  Enable it: Settings > Privacy & Security > For developers > Developer Mode" -ForegroundColor Yellow
    Write-Host ""
}

# -- 1. Check winget --
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Fail "winget not found. Install 'App Installer' from the Microsoft Store."
}
Ok "winget available"

# -- 2. Install git if missing --
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Log "Installing git..."
    winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
    # Refresh PATH
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
}
Ok "git available"

# -- 3. Clone or pull dotfiles --
if (Test-Path "$DOTFILES_DIR\.git") {
    Log "Updating existing dotfiles..."
    git -C $DOTFILES_DIR pull --rebase
} else {
    Log "Cloning dotfiles..."
    git clone $DOTFILES_REPO $DOTFILES_DIR
}
Ok "dotfiles at $DOTFILES_DIR"

# -- 4. Install Bun --
if (-not (Get-Command bun -ErrorAction SilentlyContinue)) {
    Log "Installing Bun..."
    irm bun.sh/install.ps1 | iex
    $env:PATH = "$HOME\.bun\bin;$env:PATH"
}
$bunVersion = bun --version
Ok "bun $bunVersion"

# -- 5. Install Zig (required by OpenTUI native bindings) --
if (-not (Get-Command zig -ErrorAction SilentlyContinue)) {
    Log "Installing Zig..."
    winget install -e --id zig.zig --accept-package-agreements --accept-source-agreements
    # Refresh PATH
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
}
$zigVersion = zig version
Ok "zig $zigVersion"

# -- 6. No stow needed (built-in symlinker) --
Ok "Using built-in symlinker (no stow needed)"

# -- 7. Install TUI dependencies --
Log "Installing TUI dependencies..."
Push-Location "$DOTFILES_DIR\tui"
bun install
Pop-Location
Ok "TUI dependencies installed"

# -- 8. Launch TUI --
Log "Launching dotfiles manager..."
Write-Host ""
bun run "$DOTFILES_DIR\tui\index.ts"
