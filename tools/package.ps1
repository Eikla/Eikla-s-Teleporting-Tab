param(
	[string]$Version = "dev",
	[string]$AddonName = "EiklasTeleportingTab",
	[string]$OutputDir = "dist"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $repoRoot $OutputDir
$stageDir = Join-Path $distDir $AddonName

if (Test-Path $distDir) {
	Remove-Item $distDir -Recurse -Force
}

New-Item -ItemType Directory -Path $stageDir | Out-Null

$exclude = @(".git", ".github", ".gitignore", "dist", "tools")

Get-ChildItem -Force $repoRoot |
	Where-Object { $exclude -notcontains $_.Name } |
	ForEach-Object {
		Copy-Item -Path $_.FullName -Destination $stageDir -Recurse -Force
	}

$libStubTestsPath = Join-Path $stageDir "Libs\\LibStub\\tests"
if (Test-Path $libStubTestsPath) {
	Remove-Item $libStubTestsPath -Recurse -Force
}

$zipPath = Join-Path $distDir ("{0}-{1}.zip" -f $AddonName, $Version)
Compress-Archive -Path $stageDir -DestinationPath $zipPath -Force

Write-Output ("Created package: {0}" -f $zipPath)
