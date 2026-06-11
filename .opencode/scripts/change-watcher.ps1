param(
    [string]$ProjectPath = (Resolve-Path "$PSScriptRoot\..\.."),
    [string]$OutputFile = "$ProjectPath\GUIA_CAMBIOS.md",
    [int]$PollIntervalSec = 5
)

$ErrorActionPreference = 'Continue'
$ExcludeDirs = @('build', '.gradle', '.idea', '.kotlin', '.git')
$SnapshotDir = "$ProjectPath\.opencode\snapshots"
New-Item -ItemType Directory -Path $SnapshotDir -Force | Out-Null

# ---- Helper functions ----
function Get-Relative {
    param($FullPath)
    return $FullPath.Replace($ProjectPath, '').TrimStart('\')
}

$SourceExtensions = @('.kt', '.kts', '.swift', '.xml', '.toml', '.properties', '.html', '.css', '.plist', '.pbxproj', '.xcconfig', '.js', '.gradle', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico', '.json', '.yaml', '.yml', '.txt', '.cfg', '.conf')

function Should-Ignore {
    param($RelPath)
    if ($RelPath -eq 'GUIA_CAMBIOS.md') { return $true }
    if ($RelPath -eq '.opencode' -or $RelPath -like '.opencode\*') { return $true }
    foreach ($d in $ExcludeDirs) {
        if ($RelPath -eq $d -or $RelPath.StartsWith("$d\") -or $RelPath -like "*\$d\*") { return $true }
    }
    return $false
}

function Is-SourceFile {
    param($RelPath)
    $ext = [System.IO.Path]::GetExtension($RelPath)
    return $SourceExtensions -contains $ext
}

function Get-SnapshotPath {
    param($RelPath)
    return "$SnapshotDir\$RelPath"
}

function Read-Snapshot {
    param($RelPath)
    $p = Get-SnapshotPath $RelPath
    if (Test-Path -LiteralPath $p) { return Get-Content -LiteralPath $p -Raw -ErrorAction SilentlyContinue }
    return $null
}

function Write-Snapshot {
    param($RelPath, $Content)
    $p = Get-SnapshotPath $RelPath
    $dir = Split-Path -Parent $p; New-Item -ItemType Directory -Path $dir -Force | Out-Null
    if ($Content) { Set-Content -Path $p -Value $Content -Encoding UTF8 -NoNewline } else { Set-Content -Path $p -Value "" -Encoding UTF8 -NoNewline }
}

function Remove-Snapshot {
    param($RelPath)
    $p = Get-SnapshotPath $RelPath
    if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue }
}

function Compute-Diff {
    param($OldContent, $NewContent)
    $oldLines = if ($OldContent) { $OldContent -split "`n" } else { @() }
    $newLines = if ($NewContent) { $NewContent -split "`n" } else { @() }
    if ($oldLines.Count -eq 0 -and $newLines.Count -eq 0) { return $null }
    $i = 0
    while ($i -lt $oldLines.Count -and $i -lt $newLines.Count -and $oldLines[$i] -eq $newLines[$i]) { $i++ }
    $jOld = $oldLines.Count - 1; $jNew = $newLines.Count - 1
    while ($jOld -ge $i -and $jNew -ge $i -and $oldLines[$jOld] -eq $newLines[$jNew]) { $jOld--; $jNew-- }
    $result = @()
    for ($k = $i; $k -le $jOld; $k++) { $result += "- $($oldLines[$k])" }
    for ($k = $i; $k -le $jNew; $k++) { $result += "+ $($newLines[$k])" }
    if ($result.Count -eq 0) { return $null }
    return $result
}

# ---- Initial snapshot ----
Write-Host "Tomando snapshot inicial..." -ForegroundColor Cyan
$initialFiles = Get-ChildItem -Path $ProjectPath -Recurse -File | Where-Object {
    $rel = Get-Relative $_.FullName
    -not (Should-Ignore $rel) -and (Is-SourceFile $rel)
}
foreach ($f in $initialFiles) {
    $rel = Get-Relative $f.FullName
    $content = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction SilentlyContinue
    Write-Snapshot $rel $content
}
Write-Host "Snapshots iniciales: $($initialFiles.Count) archivos" -ForegroundColor Green

# ---- Write header ----
$header = @"
# Guia de Cambios - MyApplication

> Generado automaticamente por el Change Watcher (polling cada ${PollIntervalSec}s).
> Ultima actualizacion: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Este documento registra cada modificacion hecha al proyecto, incluyendo
**el codigo exacto agregado y eliminado**, para que puedas **replicar
la aplicacion paso a paso**.

## Estado inicial del proyecto

Proyecto: **MyApplication**
Tipo: Kotlin Multiplatform (Android, Desktop, iOS, Web, Shared)
Ruta: `$ProjectPath`
Archivos monitoreados: $($initialFiles.Count)

"@
Set-Content -Path $OutputFile -Value $header -Encoding UTF8

# ---- Store known files map: relPath -> last known content hash ----
$knownFiles = @{}
foreach ($f in $initialFiles) {
    $rel = Get-Relative $f.FullName
    $knownFiles[$rel] = $true
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  CHANGE WATCHER ACTIVO (polling)" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host "Proyecto : ${ProjectPath}" -ForegroundColor Cyan
Write-Host "Output   : GUIA_CAMBIOS.md" -ForegroundColor Cyan
Write-Host "Intervalo: ${PollIntervalSec}s" -ForegroundColor Cyan
Write-Host "Excluye  : $($ExcludeDirs -join ', ')" -ForegroundColor DarkGray
Write-Host "================================================" -ForegroundColor Green
Write-Host "Presiona Ctrl+C para detener" -ForegroundColor Yellow
Write-Host ""

# ---- Polling loop ----
try {
    while ($true) {
        Start-Sleep -Seconds $PollIntervalSec

        # Get current files
        $currentFiles = @{}
        Get-ChildItem -Path $ProjectPath -Recurse -File | Where-Object {
            $rel = Get-Relative $_.FullName
            if (Should-Ignore $rel -or -not (Is-SourceFile $rel)) { return $false }
            $currentFiles[$rel] = $true
            return $true
        } | ForEach-Object {
            $rel = Get-Relative $_.FullName
            $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            
            if (-not $knownFiles.ContainsKey($rel)) {
                # NEW FILE
                Write-Host "[$ts] NUEVO: ${rel}" -ForegroundColor Green
                $content = Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue
                Write-Snapshot $rel $content
                Add-Content -Path $OutputFile -Value "`n---`n### CREADO: $rel`n`n- **Fecha:** $ts`n- **Ruta:** $rel`n- **Tipo:** CREADO" -Encoding UTF8
            } else {
                # EXISTING FILE - check for changes
                $snapContent = Read-Snapshot $rel
                $currentContent = Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue
                if ($snapContent -ne $currentContent) {
                    $diff = Compute-Diff $snapContent $currentContent
                    Write-Host "[$ts] MODIFICADO: ${rel}" -ForegroundColor Yellow
                    # Save new snapshot
                    Write-Snapshot $rel $currentContent
                    # Log entry
                    $entry = "`n---`n### MODIFICADO: $rel`n`n- **Fecha:** $ts`n- **Ruta:** $rel`n- **Tipo:** MODIFICADO"
                    if ($diff -and $diff.Count -gt 0) {
                        $entry += "`n- **Cambios:**`n``````diff"
                        foreach ($dl in $diff) { $entry += "`n$dl" }
                        $entry += "`n``````"
                    }
                    Add-Content -Path $OutputFile -Value $entry -Encoding UTF8
                }
            }
        }

        # Check for deleted files
        foreach ($rel in $knownFiles.Keys) {
            if (-not $currentFiles.ContainsKey($rel)) {
                $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Write-Host "[$ts] ELIMINADO: ${rel}" -ForegroundColor Red
                $snapContent = Read-Snapshot $rel
                $entry = "`n---`n### ELIMINADO: $rel`n`n- **Fecha:** $ts`n- **Ruta:** $rel`n- **Tipo:** ELIMINADO"
                if ($snapContent) {
                    $entry += "`n- **Contenido eliminado:**`n``````"
                    foreach ($l in ($snapContent -split "`n")) { $entry += "`n$l" }
                    $entry += "`n``````"
                }
                Add-Content -Path $OutputFile -Value $entry -Encoding UTF8
                Remove-Snapshot $rel
            }
        }

        $knownFiles = $currentFiles
    }
}
finally {
    Write-Host "Change Watcher detenido." -ForegroundColor Yellow
}
