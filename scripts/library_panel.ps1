param(
  [switch]$LibraryPanelNoRun
)

$ErrorActionPreference = "Stop"

function ConvertTo-ConfigLiteral {
  param([string]$Value)
  return "'" + ($Value -replace "'", "''") + "'"
}

function ConvertFrom-JsonStringArray {
  param([string]$Json)

  Add-Type -AssemblyName System.Web.Extensions
  $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
  $items = $serializer.DeserializeObject($Json)
  return @($items | ForEach-Object { [string]$_ })
}

function Get-LocalRagConfig {
  param(
    [string]$ConfigFile,
    [string]$ProjectDir
  )

  $defaultBaseDir = Join-Path $ProjectDir "data\documents"
  $config = @{
    BaseDirs = @($defaultBaseDir)
    BaseDir = $defaultBaseDir
    DbPath = Join-Path $ProjectDir "lancedb"
    CacheDir = Join-Path $ProjectDir "models"
  }

  if (Test-Path $ConfigFile) {
    $oldBaseDir = $env:BASE_DIR
    $oldBaseDirs = $env:BASE_DIRS
    $oldDbPath = $env:DB_PATH
    $oldCacheDir = $env:CACHE_DIR
    try {
      . $ConfigFile
      if ($env:BASE_DIRS) {
        $parsed = ConvertFrom-JsonStringArray $env:BASE_DIRS
        if ($parsed.Count -gt 0) {
          $config.BaseDirs = @($parsed | ForEach-Object { [string]$_ })
          $config.BaseDir = $config.BaseDirs[0]
        }
      } elseif ($env:BASE_DIR) {
        $config.BaseDirs = @($env:BASE_DIR)
        $config.BaseDir = $env:BASE_DIR
      }
      if ($env:DB_PATH) { $config.DbPath = $env:DB_PATH }
      if ($env:CACHE_DIR) { $config.CacheDir = $env:CACHE_DIR }
    } finally {
      $env:BASE_DIR = $oldBaseDir
      $env:BASE_DIRS = $oldBaseDirs
      $env:DB_PATH = $oldDbPath
      $env:CACHE_DIR = $oldCacheDir
    }
  }

  return [pscustomobject]$config
}

function Save-LocalRagConfig {
  param(
    [string]$ConfigFile,
    [string[]]$BaseDirs,
    [string]$BaseDir,
    [string]$ProjectDir
  )

  if ((-not $BaseDirs) -or $BaseDirs.Count -eq 0) {
    if ($BaseDir) {
      $BaseDirs = @($BaseDir)
    } else {
      $BaseDirs = @(Join-Path $ProjectDir "data\documents")
    }
  }

  $cleanBaseDirs = @(
    $BaseDirs |
      Where-Object { $_ -and $_.Trim().Length -gt 0 } |
      ForEach-Object { $_.Trim() } |
      Select-Object -Unique
  )
  if ($cleanBaseDirs.Count -eq 0) {
    throw "At least one document folder is required."
  }

  $configDir = Split-Path -Parent $ConfigFile
  $dbPath = Join-Path $ProjectDir "lancedb"
  $cacheDir = Join-Path $ProjectDir "models"
  New-Item -ItemType Directory -Force -Path $configDir, $dbPath, $cacheDir | Out-Null
  foreach ($dir in $cleanBaseDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }

  $json = ConvertTo-Json -InputObject @($cleanBaseDirs) -Compress
  $content = @(
    "# Local machine config for local-Rag.",
    "# This file is ignored by Git.",
    "# BASE_DIR is kept for compatibility; BASE_DIRS is the multi-folder source of truth.",
    "`$env:BASE_DIR = $(ConvertTo-ConfigLiteral $cleanBaseDirs[0])",
    "`$env:BASE_DIRS = $(ConvertTo-ConfigLiteral $json)",
    "`$env:DB_PATH = $(ConvertTo-ConfigLiteral $dbPath)",
    "`$env:CACHE_DIR = $(ConvertTo-ConfigLiteral $cacheDir)"
  ) -join [Environment]::NewLine

  Set-Content -LiteralPath $ConfigFile -Value $content -Encoding UTF8
}

function Invoke-LocalRagPanelCommand {
  param(
    [string]$ProjectDir,
    [string]$Mode
  )

  $script = Join-Path $ProjectDir "scripts\silent_start.ps1"
  $process = Start-Process -FilePath "powershell.exe" -ArgumentList @(
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    $script,
    "-Mode",
    $Mode
  ) -WorkingDirectory $ProjectDir -WindowStyle Hidden -PassThru
  return $process
}

function Show-LocalRagLibraryPanel {
  $projectDir = Split-Path -Parent $PSScriptRoot
  $configFile = Join-Path $projectDir "config\local-rag.env.ps1"
  $logFile = Join-Path $projectDir "logs\silent-start.log"

  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing

  [System.Windows.Forms.Application]::EnableVisualStyles()

  $form = New-Object System.Windows.Forms.Form
  $form.Text = "local-Rag 资料库"
  $form.StartPosition = "CenterScreen"
  $form.Size = New-Object System.Drawing.Size(720, 420)
  $form.MinimumSize = New-Object System.Drawing.Size(660, 360)

  $title = New-Object System.Windows.Forms.Label
  $title.Text = "local-Rag 资料库入库面板"
  $title.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 13, [System.Drawing.FontStyle]::Bold)
  $title.AutoSize = $true
  $title.Location = New-Object System.Drawing.Point(18, 18)
  $form.Controls.Add($title)

  $hint = New-Object System.Windows.Forms.Label
  $hint.Text = "可以添加多个资料文件夹。更新入库会递归处理每个文件夹和它们的所有子文件夹。"
  $hint.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
  $hint.AutoSize = $true
  $hint.Location = New-Object System.Drawing.Point(20, 52)
  $form.Controls.Add($hint)

  $pathLabel = New-Object System.Windows.Forms.Label
  $pathLabel.Text = "资料文件夹列表："
  $pathLabel.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9, [System.Drawing.FontStyle]::Bold)
  $pathLabel.AutoSize = $true
  $pathLabel.Location = New-Object System.Drawing.Point(20, 88)
  $form.Controls.Add($pathLabel)

  $listBox = New-Object System.Windows.Forms.ListBox
  $listBox.Location = New-Object System.Drawing.Point(20, 115)
  $listBox.Size = New-Object System.Drawing.Size(660, 140)
  $listBox.HorizontalScrollbar = $true
  $form.Controls.Add($listBox)

  $statusLabel = New-Object System.Windows.Forms.Label
  $statusLabel.Text = "准备就绪"
  $statusLabel.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
  $statusLabel.AutoSize = $true
  $statusLabel.Location = New-Object System.Drawing.Point(20, 342)
  $form.Controls.Add($statusLabel)

  $addButton = New-Object System.Windows.Forms.Button
  $addButton.Text = "添加文件夹"
  $addButton.Location = New-Object System.Drawing.Point(20, 270)
  $addButton.Size = New-Object System.Drawing.Size(105, 34)
  $form.Controls.Add($addButton)

  $removeButton = New-Object System.Windows.Forms.Button
  $removeButton.Text = "移除选中"
  $removeButton.Location = New-Object System.Drawing.Point(137, 270)
  $removeButton.Size = New-Object System.Drawing.Size(105, 34)
  $form.Controls.Add($removeButton)

  $clearButton = New-Object System.Windows.Forms.Button
  $clearButton.Text = "清空列表"
  $clearButton.Location = New-Object System.Drawing.Point(254, 270)
  $clearButton.Size = New-Object System.Drawing.Size(95, 34)
  $form.Controls.Add($clearButton)

  $updateButton = New-Object System.Windows.Forms.Button
  $updateButton.Text = "更新全部入库"
  $updateButton.Location = New-Object System.Drawing.Point(366, 270)
  $updateButton.Size = New-Object System.Drawing.Size(120, 34)
  $form.Controls.Add($updateButton)

  $statusButton = New-Object System.Windows.Forms.Button
  $statusButton.Text = "查看状态"
  $statusButton.Location = New-Object System.Drawing.Point(498, 270)
  $statusButton.Size = New-Object System.Drawing.Size(90, 34)
  $form.Controls.Add($statusButton)

  $logButton = New-Object System.Windows.Forms.Button
  $logButton.Text = "打开日志"
  $logButton.Location = New-Object System.Drawing.Point(600, 270)
  $logButton.Size = New-Object System.Drawing.Size(80, 34)
  $form.Controls.Add($logButton)

  $openConfigButton = New-Object System.Windows.Forms.Button
  $openConfigButton.Text = "打开配置"
  $openConfigButton.Location = New-Object System.Drawing.Point(20, 310)
  $openConfigButton.Size = New-Object System.Drawing.Size(105, 30)
  $form.Controls.Add($openConfigButton)

  $closeButton = New-Object System.Windows.Forms.Button
  $closeButton.Text = "关闭"
  $closeButton.Location = New-Object System.Drawing.Point(600, 310)
  $closeButton.Size = New-Object System.Drawing.Size(80, 30)
  $form.Controls.Add($closeButton)

  function Get-ListBoxPaths {
    $paths = New-Object System.Collections.Generic.List[string]
    foreach ($item in $listBox.Items) {
      $paths.Add([string]$item)
    }
    return @($paths.ToArray())
  }

  function Save-PanelList {
    $paths = Get-ListBoxPaths
    if ($paths.Count -eq 0) {
      $statusLabel.Text = "请至少添加一个资料文件夹"
      return $false
    }
    Save-LocalRagConfig -ConfigFile $configFile -BaseDirs $paths -ProjectDir $projectDir
    return $true
  }

  function Refresh-PanelConfig {
    $listBox.Items.Clear()
    $config = Get-LocalRagConfig -ConfigFile $configFile -ProjectDir $projectDir
    foreach ($path in $config.BaseDirs) {
      [void]$listBox.Items.Add($path)
    }
    return $config
  }

  function Ensure-FoldersSelected {
    if ($listBox.Items.Count -gt 0) {
      return $true
    }
    $result = [System.Windows.Forms.MessageBox]::Show(
      "还没有添加资料文件夹。现在添加吗？",
      "local-Rag",
      [System.Windows.Forms.MessageBoxButtons]::YesNo,
      [System.Windows.Forms.MessageBoxIcon]::Question
    )
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
      return $false
    }
    $addButton.PerformClick()
    return ($listBox.Items.Count -gt 0)
  }

  $addButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "选择要入库的资料文件夹"
    $dialog.ShowNewFolderButton = $true
    if ($listBox.SelectedItem -and (Test-Path ([string]$listBox.SelectedItem))) {
      $dialog.SelectedPath = [string]$listBox.SelectedItem
    }
    if ($dialog.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
      $selected = $dialog.SelectedPath
      $exists = $false
      foreach ($item in $listBox.Items) {
        if ([string]$item -eq $selected) {
          $exists = $true
          break
        }
      }
      if (-not $exists) {
        [void]$listBox.Items.Add($selected)
      }
      if (Save-PanelList) {
        $statusLabel.Text = "已保存资料文件夹列表"
      }
    }
  })

  $removeButton.Add_Click({
    if ($listBox.SelectedIndex -ge 0) {
      $listBox.Items.RemoveAt($listBox.SelectedIndex)
      if (Save-PanelList) {
        $statusLabel.Text = "已移除选中文件夹"
      }
    }
  })

  $clearButton.Add_Click({
    $result = [System.Windows.Forms.MessageBox]::Show(
      "确定清空资料文件夹列表吗？",
      "local-Rag",
      [System.Windows.Forms.MessageBoxButtons]::YesNo,
      [System.Windows.Forms.MessageBoxIcon]::Question
    )
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
      $listBox.Items.Clear()
      $statusLabel.Text = "列表已清空，请添加资料文件夹"
    }
  })

  $updateButton.Add_Click({
    if (-not (Ensure-FoldersSelected)) { return }
    if (-not (Save-PanelList)) { return }
    $statusLabel.Text = "正在后台更新全部入库，可在日志中查看进度..."
    Invoke-LocalRagPanelCommand -ProjectDir $projectDir -Mode "update" | Out-Null
  })

  $statusButton.Add_Click({
    if (-not (Ensure-FoldersSelected)) { return }
    if (-not (Save-PanelList)) { return }
    $statusLabel.Text = "正在后台检查状态..."
    Invoke-LocalRagPanelCommand -ProjectDir $projectDir -Mode "status" | Out-Null
  })

  $logButton.Add_Click({
    $logDir = Split-Path -Parent $logFile
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    if (-not (Test-Path $logFile)) {
      Set-Content -LiteralPath $logFile -Value "local-Rag 日志尚无内容。" -Encoding UTF8
    }
    Start-Process notepad.exe $logFile
  })

  $openConfigButton.Add_Click({
    if (-not (Test-Path $configFile)) {
      Save-PanelList | Out-Null
    }
    Start-Process notepad.exe $configFile
  })

  $closeButton.Add_Click({
    $form.Close()
  })

  Refresh-PanelConfig | Out-Null
  $form.Add_Shown({
    if ($listBox.Items.Count -eq 0) {
      $statusLabel.Text = "请添加资料文件夹"
    }
  })

  [void]$form.ShowDialog()
}

if (-not $LibraryPanelNoRun) {
  Show-LocalRagLibraryPanel
}
