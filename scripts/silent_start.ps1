param(
  [ValidateSet("update", "status", "prewarm")]
  [string]$Mode = "update"
)

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path $ProjectDir "logs"
$ConfigFile = Join-Path $ProjectDir "config\local-rag.env.ps1"
$LogFile = Join-Path $LogDir "silent-start.log"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Write-Log {
  param([string]$Message)
  $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Add-Content -LiteralPath $LogFile -Value "[$stamp] $Message" -Encoding UTF8
}

function Invoke-LoggedNative {
  param(
    [string]$Command,
    [string[]]$Arguments
  )

  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try {
    $output = & $Command @Arguments 2>&1
    $exitCode = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $oldPreference
  }

  foreach ($line in $output) {
    Write-Log ([string]$line)
  }

  if ($exitCode -ne 0) {
    throw "$Command exited with code $exitCode"
  }
}

function ConvertFrom-JsonStringArray {
  param([string]$Json)

  Add-Type -AssemblyName System.Web.Extensions
  $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
  $items = $serializer.DeserializeObject($Json)
  return @($items | ForEach-Object { [string]$_ })
}

function ConvertTo-JsonStringArray {
  param([string[]]$Items)

  Add-Type -AssemblyName System.Web.Extensions
  $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
  return $serializer.Serialize([string[]]$Items)
}

try {
  Write-Log "Starting local-Rag silent task. Mode=$Mode"
  Set-Location $ProjectDir

  if (Test-Path $ConfigFile) {
    . $ConfigFile
    Write-Log "Loaded config: $ConfigFile"
  }

  if ($env:BASE_DIRS) {
    $baseDirs = ConvertFrom-JsonStringArray $env:BASE_DIRS
  } elseif ($env:BASE_DIR) {
    $baseDirs = @($env:BASE_DIR)
  } else {
    $baseDirs = @(Join-Path $ProjectDir "data\documents")
  }
  $baseDirs = @($baseDirs | Where-Object { $_ -and $_.Trim().Length -gt 0 } | Select-Object -Unique)
  if ($baseDirs.Count -eq 0) {
    throw "No document folders configured."
  }
  $env:BASE_DIR = $baseDirs[0]
  $env:BASE_DIRS = ConvertTo-JsonStringArray $baseDirs

  if (-not $env:DB_PATH) {
    $env:DB_PATH = Join-Path $ProjectDir "lancedb"
  }
  if (-not $env:CACHE_DIR) {
    $env:CACHE_DIR = Join-Path $ProjectDir "models"
  }

  New-Item -ItemType Directory -Force -Path $env:DB_PATH, $env:CACHE_DIR | Out-Null
  foreach ($dir in $baseDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }

  $Entry = Join-Path $ProjectDir "dist\index.js"
  if (-not (Test-Path $Entry)) {
    Write-Log "dist\index.js not found. Running build."
    Invoke-LoggedNative -Command "corepack" -Arguments @("pnpm", "run", "build")
  }

  if ($Mode -eq "update") {
    Write-Log "Running directory ingest/update for $($baseDirs.Count) folder(s)."
    $baseDirArgs = @()
    foreach ($dir in $baseDirs) {
      $baseDirArgs += @("--base-dir", $dir)
    }
    foreach ($dir in $baseDirs) {
      Write-Log "Updating folder: $dir"
      $arguments = @($Entry, "ingest") + $baseDirArgs + @($dir)
      Invoke-LoggedNative -Command "node" -Arguments $arguments
    }
    Write-Log "Running post-update status."
    Invoke-LoggedNative -Command "node" -Arguments @($Entry, "status")
  } elseif ($Mode -eq "prewarm") {
    Write-Log "Running prewarm status."
    Invoke-LoggedNative -Command "node" -Arguments @($Entry, "status")
  } else {
    Write-Log "Running status check."
    Invoke-LoggedNative -Command "node" -Arguments @($Entry, "status")
  }

  Write-Log "local-Rag silent task finished."
} catch {
  Write-Log "ERROR: $($_.Exception.Message)"
  exit 1
}
