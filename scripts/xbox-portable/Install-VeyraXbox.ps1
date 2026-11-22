[CmdletBinding()]
param(
    [string]$Destination = (Join-Path $env:LOCALAPPDATA 'Programs/Veyra Xbox NVIDIA 2.2.1'),
    [string]$UpstreamZip,
    [string]$DlssSrDll
)

$ErrorActionPreference = 'Stop'
$destinationPath = [IO.Path]::GetFullPath($Destination)
$parent = [IO.Path]::GetDirectoryName($destinationPath)
if (!$parent -or (Test-Path -LiteralPath $destinationPath)) {
    throw 'Choose a new directory for the side-by-side installation.'
}
$null = New-Item -ItemType Directory -Force -Path $parent
$parent = (Resolve-Path -LiteralPath $parent).Path
$destinationPath = Join-Path $parent ([IO.Path]::GetFileName($destinationPath))
$stage = Join-Path $parent ('.veyra-xbox-setup-' + [Guid]::NewGuid().ToString('N'))
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'payload.json') -Raw | ConvertFrom-Json
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
        & curl.exe --fail --location --retry 2 --output $Path -- $Url
        if ($LASTEXITCODE -ne 0) { throw "Download failed: $Filename" }
    }
    $Path = (Resolve-Path -LiteralPath $Path).Path
    Assert-Hash $Path $Hash
    return $Path
}

foreach ($entry in $manifest.files) {
    if ($entry.path -notmatch '^(Veyra\.exe|versions/2\.2\.1/(veyra_qml_ui\.exe|veyra_update_worker\.exe|qml/Veyra/XboxSourceDialog\.qml|shaders/[A-Za-z0-9_]+\.dxil|virtualcam/[A-Za-z0-9_.-]+\.(exe|dll)))$') {
        throw "Unexpected payload path: $($entry.path)"
    }
    Assert-Hash (Join-Path $payload $entry.path) $entry.sha256
}

try {
    $null = New-Item -ItemType Directory -Path $stage
    $donor = Get-VerifiedAsset $UpstreamZip `
        'https://github.com/Likely7/Veyra-NRVideo/releases/download/v2.2.0/Veyra-2.2.0-NVIDIA-win64-portable.zip' `
        'Veyra-2.2.0-NVIDIA-win64-portable.zip' 'FD1235483A6E36B2520966EC161104478CD93186E97AF3B0D78D2DFA7B129932'
    $sr = Get-VerifiedAsset $DlssSrDll `
        'https://raw.githubusercontent.com/NVIDIA/DLSS/v310.9.16/lib/Windows_x86_64/rel/nvngx_dlss.dll' `
        'nvngx_dlss.dll' 'D00B5B0AB29C3CA101B70C3A5ECB3A01B7EF33766A3383A28A18623083E6123E'
    $signature = Get-AuthenticodeSignature -LiteralPath $sr
    if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notlike '*O=NVIDIA Corporation*') {
        throw 'The DLSS SR signature could not be verified.'
    }
    Write-Host 'Extracting the verified upstream NVIDIA package'
    & tar.exe -xf $donor -C $stage
    if ($LASTEXITCODE -ne 0) { throw 'Upstream package extraction failed.' }
    $app = Join-Path $stage 'Veyra-2.2.0-NVIDIA-win64-portable'
    $versionRoot = Join-Path $app 'versions/2.2.1'
    $previousRoot = (Resolve-Path -LiteralPath (Join-Path $app 'versions/2.2.0')).Path
    if ([IO.Path]::GetDirectoryName($previousRoot) -ne (Join-Path $app 'versions')) {
        throw 'Unexpected upstream version path.'
    }
    Move-Item -LiteralPath $previousRoot -Destination $versionRoot
    foreach ($entry in $manifest.files) {
        $target = Join-Path $app $entry.path
        Copy-Item -LiteralPath (Join-Path $payload $entry.path) -Destination $target -Force
        Assert-Hash $target $entry.sha256
    }
    $srTarget = Join-Path $versionRoot 'runtime/experimental/nvngx_dlss.dll'
    Copy-Item -LiteralPath $sr -Destination $srTarget -Force
    Assert-Hash $srTarget 'D00B5B0AB29C3CA101B70C3A5ECB3A01B7EF33766A3383A28A18623083E6123E'
    [IO.File]::WriteAllText((Join-Path $app 'current-version.txt'), "2.2.1`n`n", [Text.Encoding]::ASCII)
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'payload.json') -Destination (Join-Path $app 'LOCAL-BUILD.json')
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'README.md') -Destination (Join-Path $app 'Xbox-NVIDIA-Guide.md')
    if (Test-Path -LiteralPath $destinationPath) { throw 'The destination appeared during setup.' }
    Move-Item -LiteralPath $app -Destination $destinationPath
    Write-Host "Installed. Launch $destinationPath\Veyra.exe"
} finally {
    if (Test-Path -LiteralPath $stage) {
        $resolvedStage = (Resolve-Path -LiteralPath $stage).Path
        $isLink = (Get-Item -LiteralPath $resolvedStage -Force).Attributes -band [IO.FileAttributes]::ReparsePoint
        if (!$isLink -and $resolvedStage -eq $stage -and [IO.Path]::GetDirectoryName($resolvedStage) -eq $parent) {
            Remove-Item -LiteralPath $resolvedStage -Recurse -Force
        }
    }
}
