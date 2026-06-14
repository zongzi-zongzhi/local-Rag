$ErrorActionPreference = "Stop"

$ProjectDir = Split-Path -Parent $PSScriptRoot
$PanelScript = Join-Path $ProjectDir "scripts\library_panel.ps1"
$TestRoot = Join-Path $ProjectDir "tmp\panel-test"
$TestConfig = Join-Path $TestRoot "local-rag.env.ps1"
$DocsDir = Join-Path $TestRoot "docs"
$MoreDocsDir = Join-Path $TestRoot "more-docs"

Remove-Item -LiteralPath $TestRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $DocsDir, $MoreDocsDir | Out-Null

. $PanelScript -LibraryPanelNoRun

Save-LocalRagConfig -ConfigFile $TestConfig -BaseDirs @($DocsDir, $MoreDocsDir) -ProjectDir $ProjectDir
$config = Get-LocalRagConfig -ConfigFile $TestConfig -ProjectDir $ProjectDir

if ($config.BaseDirs.Count -ne 2) {
  throw "Expected two BaseDirs, got $($config.BaseDirs.Count)"
}

if ($config.BaseDirs[0] -ne $DocsDir) {
  throw "First BaseDir was not persisted. Expected '$DocsDir', got '$($config.BaseDirs[0])'"
}

if ($config.BaseDirs[1] -ne $MoreDocsDir) {
  throw "Second BaseDir was not persisted. Expected '$MoreDocsDir', got '$($config.BaseDirs[1])'"
}

if ($config.BaseDir -ne $DocsDir) {
  throw "Compatibility BaseDir should be first BaseDirs item. Expected '$DocsDir', got '$($config.BaseDir)'"
}

$savedText = Get-Content -LiteralPath $TestConfig -Raw -Encoding UTF8
if ($savedText -notmatch "BASE_DIRS") {
  throw "Config did not write BASE_DIRS"
}

if ($config.DbPath -ne (Join-Path $ProjectDir "lancedb")) {
  throw "DbPath default mismatch: $($config.DbPath)"
}

if ($config.CacheDir -ne (Join-Path $ProjectDir "models")) {
  throw "CacheDir default mismatch: $($config.CacheDir)"
}

Remove-Item -LiteralPath $TestRoot -Recurse -Force -ErrorAction SilentlyContinue
Write-Output "library_panel self-test passed"
