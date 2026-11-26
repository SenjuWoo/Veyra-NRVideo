[CmdletBinding()]
param(
    [string]$Destination = (Join-Path $env:LOCALAPPDATA 'Programs/Veyra Xbox NVIDIA 2.2.4'),
    [string]$UpstreamZip,
    [string]$DlssSrDll,
    # Root of an earlier Veyra portable folder. Its presets, settings and LUTs are copied into the new one.
    [string]$CopySettingsFrom,
    [switch]$Launch
)

$ErrorActionPreference = 'Stop'
$version = '2.2.4'
$base = '2.2.1'
$destinationPath = [IO.Path]::GetFullPath($Destination)
$parent = [IO.Path]::GetDirectoryName($destinationPath)
if (!$parent -or (Test-Path -LiteralPath $destinationPath)) {
    throw 'Choose a new directory for the side-by-side installation.'
}
$oldProfile = $null
if ($CopySettingsFrom) {
    $oldProfile = Join-Path ([IO.Path]::GetFullPath($CopySettingsFrom)) 'runtime_local'
    if (!(Test-Path -LiteralPath (Join-Path $oldProfile 'user-data-2.0.0') -PathType Container)) {
        throw 'CopySettingsFrom has no runtime_local/user-data-2.0.0 folder.'
    }
}
$null = New-Item -ItemType Directory -Force -Path $parent
$parent = (Resolve-Path -LiteralPath $parent).Path
$destinationPath = Join-Path $parent ([IO.Path]::GetFileName($destinationPath))
$stage = Join-Path $parent ('.veyra-xbox-setup-' + [Guid]::NewGuid().ToString('N'))
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'payload.json') -Raw | ConvertFrom-Json
# Windows' own tools: a GNU tar earlier on PATH reads "C:" as a remote host.
$curl = Join-Path $env:SystemRoot 'System32/curl.exe'
$tar = Join-Path $env:SystemRoot 'System32/tar.exe'
$payload = Join-Path $PSScriptRoot 'payload'

function Assert-Hash([string]$Path, [string]$Expected) {
    if ((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash -ne $Expected) {
        throw "SHA-256 mismatch: $([IO.Path]::GetFileName($Path))"
    }
}

function Get-VerifiedAsset([string]$Path, [string]$Url, [string]$Filename, [string]$Hash) {
    if (!$Path) {
        $Path = Join-Path $stage $Filename
        Write-Host "Downloading $Filename"
        & $curl --fail --location --retry 2 --output $Path -- $Url
        if ($LASTEXITCODE -ne 0) { throw "Download failed: $Filename" }
    }
    $Path = (Resolve-Path -LiteralPath $Path).Path
    Assert-Hash $Path $Hash
    return $Path
}

if ($manifest.version -ne $version) { throw "This installer expects payload $version." }
$allowed = '^(versions/' + [regex]::Escape($version) + '/(veyra_qml_ui\.exe|qml/Veyra/(XboxSourceDialog|SettingsPage)\.qml)|presets/[A-Za-z0-9 ._-]+\.vpreset)$'
foreach ($entry in $manifest.files) {
    if ($entry.path -notmatch $allowed) { throw "Unexpected payload path: $($entry.path)" }
    Assert-Hash (Join-Path $payload $entry.path) $entry.sha256
}

try {
    $null = New-Item -ItemType Directory -Path $stage
    $donor = Get-VerifiedAsset $UpstreamZip `
        "https://github.com/Likely7/Veyra-NRVideo/releases/download/v$base/Veyra-$base-NVIDIA-win64-portable.zip" `
        "Veyra-$base-NVIDIA-win64-portable.zip" 'E09150D1594AA9416FA27457A42B4D50B5D814E05471216BEF95B9303544386B'
    $sr = Get-VerifiedAsset $DlssSrDll `
        'https://raw.githubusercontent.com/NVIDIA/DLSS/v310.9.16/lib/Windows_x86_64/rel/nvngx_dlss.dll' `
        'nvngx_dlss.dll' 'D00B5B0AB29C3CA101B70C3A5ECB3A01B7EF33766A3383A28A18623083E6123E'
    $signature = Get-AuthenticodeSignature -LiteralPath $sr
    if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notlike '*O=NVIDIA Corporation*') {
        throw 'The DLSS SR signature could not be verified.'
    }
    Write-Host 'Extracting the verified upstream NVIDIA package'
    & $tar -xf $donor -C $stage
    if ($LASTEXITCODE -ne 0) { throw 'Upstream package extraction failed.' }
    $app = Join-Path $stage "Veyra-$base-NVIDIA-win64-portable"
    $versionRoot = Join-Path $app "versions/$version"
    $previousRoot = (Resolve-Path -LiteralPath (Join-Path $app "versions/$base")).Path
    if ([IO.Path]::GetDirectoryName($previousRoot) -ne (Join-Path $app 'versions')) {
        throw 'Unexpected upstream version path.'
    }
    Move-Item -LiteralPath $previousRoot -Destination $versionRoot
    foreach ($entry in $manifest.files) {
        $target = Join-Path $app $entry.path
        $null = New-Item -ItemType Directory -Force -Path ([IO.Path]::GetDirectoryName($target))
        Copy-Item -LiteralPath (Join-Path $payload $entry.path) -Destination $target -Force
        Assert-Hash $target $entry.sha256
    }
    $srTarget = Join-Path $versionRoot 'runtime/experimental/nvngx_dlss.dll'
    Copy-Item -LiteralPath $sr -Destination $srTarget -Force
    Assert-Hash $srTarget 'D00B5B0AB29C3CA101B70C3A5ECB3A01B7EF33766A3383A28A18623083E6123E'
    [IO.File]::WriteAllText((Join-Path $app 'current-version.txt'), "$version`n`n", [Text.Encoding]::ASCII)
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'payload.json') -Destination (Join-Path $app 'LOCAL-BUILD.json')
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'README.md') -Destination (Join-Path $app 'Xbox-NVIDIA-Guide.md')
    if ($oldProfile) {
        # The profile is shared by every version in a portable folder, so the earlier one carries over as is.
        $newProfile = Join-Path $app 'runtime_local'
        $null = New-Item -ItemType Directory -Force -Path $newProfile
        foreach ($folder in 'user-data-2.0.0', 'luts') {
            $from = Join-Path $oldProfile $folder
            if (Test-Path -LiteralPath $from -PathType Container) {
                Copy-Item -LiteralPath $from -Destination $newProfile -Recurse
            }
        }
        Write-Host 'Copied presets, settings and LUTs from the earlier installation'
    }
    if (Test-Path -LiteralPath $destinationPath) { throw 'The destination appeared during setup.' }
    Move-Item -LiteralPath $app -Destination $destinationPath
    Write-Host "Installed. Launch $destinationPath\Veyra.exe"
    Write-Host "Example presets are in $destinationPath\presets (Presets > Import)."
} finally {
    if (Test-Path -LiteralPath $stage) {
        $resolvedStage = (Resolve-Path -LiteralPath $stage).Path
        $isLink = (Get-Item -LiteralPath $resolvedStage -Force).Attributes -band [IO.FileAttributes]::ReparsePoint
        if (!$isLink -and $resolvedStage -eq $stage -and [IO.Path]::GetDirectoryName($resolvedStage) -eq $parent) {
            Remove-Item -LiteralPath $resolvedStage -Recurse -Force
        }
    }
}

if ($Launch) {
    Start-Process -FilePath (Join-Path $destinationPath 'Veyra.exe') -WorkingDirectory $destinationPath
}
