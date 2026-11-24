<#
Stages the Xbox/NVIDIA patch ZIP from a finished build.

The ZIP carries the player, the two changed QML files and the example presets.
Setup adds them to the official NVIDIA portable package, which it downloads and
verifies itself. The launcher, update worker, shaders, virtual camera and every
runtime DLL stay the official ones.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Build,      # CMake build directory holding veyra_qml_ui.exe
    [Parameter(Mandatory)][string]$Output,     # new directory for the ZIP and SHA256SUMS.txt
    [string]$Commit                            # expected HEAD of this checkout
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$sha = (git -C $root rev-parse HEAD).Trim()
if ($LASTEXITCODE) { throw 'Not a Git checkout.' }
if ($Commit -and $sha -ne $Commit) { throw "Release commit mismatch: checkout is $sha" }
if (git -C $root status --porcelain) { throw 'Commit or discard local changes before packaging.' }
$project = Select-String -LiteralPath (Join-Path $root 'CMakeLists.txt') -Pattern '^project\(veyra VERSION (\d+\.\d+\.\d+) ' |
    Select-Object -First 1
if (!$project) { throw 'Project version not found.' }
$version = $project.Matches[0].Groups[1].Value
$build = (Resolve-Path -LiteralPath $Build).Path
$player = Join-Path $build 'veyra_qml_ui.exe'
if ((Get-Item -LiteralPath $player).VersionInfo.ProductVersion -ne $version) { throw 'The build is not this version.' }
$Output = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Output)   # payload paths are cut from it
if (Test-Path -LiteralPath $Output) { throw 'Output directory already exists.' }
$stage = Join-Path $Output 'stage'
$payload = Join-Path $stage 'payload'
$versionRoot = Join-Path $payload "versions/$version"
$null = New-Item -ItemType Directory -Force -Path (Join-Path $versionRoot 'qml/Veyra'), (Join-Path $payload 'presets')
foreach ($file in 'Install.cmd', 'Install-VeyraXbox.ps1', 'README.md') {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $file) -Destination $stage
}
Copy-Item -LiteralPath (Join-Path $root 'LICENSE') -Destination $stage
Copy-Item -LiteralPath $player -Destination $versionRoot
foreach ($qml in 'XboxSourceDialog.qml', 'SettingsPage.qml') {
    Copy-Item -LiteralPath (Join-Path $root "qml/Veyra/$qml") -Destination (Join-Path $versionRoot 'qml/Veyra')
}
Copy-Item -Path (Join-Path $PSScriptRoot 'presets/*.vpreset') -Destination (Join-Path $payload 'presets')
$items = @(Get-ChildItem -LiteralPath $payload -Recurse -File | Sort-Object FullName | ForEach-Object {
    @{ path = $_.FullName.Substring($payload.Length + 1).Replace('\', '/'); sha256 = (Get-FileHash -LiteralPath $_.FullName).Hash }
})
@{ source = $sha; version = $version; files = $items } | ConvertTo-Json -Depth 5 |
    Set-Content -LiteralPath (Join-Path $stage 'payload.json') -Encoding utf8
$archive = Join-Path $Output "Veyra-$version-Xbox-NVIDIA-Patch.zip"
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $archive -CompressionLevel Optimal
$hash = (Get-FileHash -LiteralPath $archive).Hash.ToLowerInvariant()
# LF line ending: `sha256sum -c` treats a trailing CR as part of the file name.
[IO.File]::WriteAllText((Join-Path $Output 'SHA256SUMS.txt'), "$hash  $([IO.Path]::GetFileName($archive))`n")
@{ source = $sha; version = $version; archive = $archive; sha256 = $hash; payloadFiles = $items.Count } | ConvertTo-Json
