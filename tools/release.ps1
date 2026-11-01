# Flowra Release Helper for Windows PowerShell
param (
    [string]$bump = "patch",
    [string]$notes = "",
    [switch]$skipBuild
)

$argsList = @("run", "tools/release.dart", "--bump", $bump)

if ($notes -ne "") {
    $argsList += @("--notes", $notes)
}

if ($skipBuild) {
    $argsList += @("--skip-build")
}

Write-Host "Executing: dart $($argsList -join ' ')" -ForegroundColor Cyan
& dart $argsList
