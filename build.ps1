[CmdletBinding()]
param(
    [ValidateSet('Debug','Release')]
    [string]$Configuration = 'Release',

    [switch]$SkipTests,

    [string]$NewVersion,

    [string]$Repository,

    [string]$NuGetApiKey
)

$ErrorActionPreference = 'Stop'

$moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $moduleRoot
$manifestPath = Join-Path $moduleRoot 'EvoPartnerAPICommandlet.psd1'
$outDir = Join-Path $root 'out'

Write-Host "Building EvoPartnerAPICommandlet ($Configuration)..." -ForegroundColor Cyan

if (-not (Test-Path $manifestPath)) {
    throw "Module manifest not found at '$manifestPath'."
}

if ($NewVersion) {
    Write-Host "Updating module version to $NewVersion" -ForegroundColor Cyan
    if (-not (Get-Command Update-ModuleManifest -ErrorAction SilentlyContinue)) {
        throw 'Update-ModuleManifest (PowerShellGet) is required to bump the module version.'
    }

    Update-ModuleManifest -Path $manifestPath -ModuleVersion $NewVersion
}

if (-not $SkipTests) {
    if (Get-Command Invoke-Pester -ErrorAction SilentlyContinue) {
        Write-Host 'Running Pester tests...' -ForegroundColor Cyan
        $testsPath = Join-Path $moduleRoot 'Tests'
        if (Test-Path $testsPath) {
            Invoke-Pester -Path $testsPath
        }
        else {
            Write-Warning "No Tests folder found at '$testsPath'. Skipping tests."
        }
    }
    else {
        Write-Warning 'Pester is not installed. Skipping tests. Install the Pester module to enable automated testing.'
    }
}

if (Test-Path $outDir) {
    Write-Host "Cleaning output directory '$outDir'" -ForegroundColor Cyan
    Remove-Item -Recurse -Force $outDir
}

New-Item -ItemType Directory -Path $outDir | Out-Null

$moduleOut = Join-Path $outDir 'EvoPartnerAPICommandlet'
Write-Host "Copying module to '$moduleOut'" -ForegroundColor Cyan

if (-not (Test-Path $moduleOut)) {
    New-Item -ItemType Directory -Path $moduleOut | Out-Null
}

$itemsToCopy = @(
    'EvoPartnerAPICommandlet.psd1'
    'EvoPartnerAPICommandlet.psm1'
    'Public'
    'Private'
    'README.md'
)

$oldProgressPreference = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
try {
    foreach ($item in $itemsToCopy) {
        $source = Join-Path $moduleRoot $item
        if (Test-Path $source) {
            Copy-Item -Recurse -Path $source -Destination $moduleOut
        }
    }
}
finally {
    $ProgressPreference = $oldProgressPreference
}

if ($Repository) {
    if (-not (Get-Command Publish-Module -ErrorAction SilentlyContinue)) {
        throw 'Publish-Module (PowerShellGet) is required to publish to a repository.'
    }

    Write-Host "Publishing module to repository '$Repository'" -ForegroundColor Cyan
    $publishParams = @{
        Path       = $moduleOut
        Repository = $Repository
        Force      = $true
    }

    if ($NuGetApiKey) {
        $publishParams['NuGetApiKey'] = $NuGetApiKey
    }

    Publish-Module @publishParams
}

Write-Host 'Build complete.' -ForegroundColor Green
