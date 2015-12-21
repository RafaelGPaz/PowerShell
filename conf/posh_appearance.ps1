# PowerShell appearance

try {
    # Check if git is on PATH, i.e. Git already installed on system
    Get-command -Name "git" -ErrorAction Stop >$null
} catch {
    $env:Path += ";$env:CMDER_ROOT\vendor\git-for-windows\bin"
}

try {
    Import-Module -Name "posh-git" -ErrorAction Stop >$null
    $gitStatus = $true
} catch {
    Write-Warning "Missing git support, install posh-git with 'Install-Module posh-git' and restart cmder."
    $gitStatus = $false
}

function checkGit($Path) {
    if (Test-Path -Path (Join-Path $Path '.git/') ) {
        Write-VcsStatus
        return
    }
    $SplitPath = split-path $path
    if ($SplitPath) {
        checkGit($SplitPath)
    }
}

# Set up a Cmder prompt, adding the git prompt parts inside git repos
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    $Host.UI.RawUI.ForegroundColor = "White"
    Write-Host $pwd.ProviderPath -NoNewLine -ForegroundColor Green
    if($gitStatus){
        checkGit($pwd.ProviderPath)
    }
    $global:LASTEXITCODE = $realLASTEXITCODE
    Write-Host "`nλ" -NoNewLine -ForegroundColor "DarkGray"
    return " "
}

# Set Terminal colors
if ( $Host.Name -eq "ConsoleHost" ) {
$bgcolor = "Black"

$rui = (Get-Host).UI.RawUI
$rui.BackgroundColor = "$bgcolor"
$rui.ForegroundColor = "White"

$pdata = (Get-Host).PrivateData
$pdata.ErrorForegroundColor    = "Red"
$pdata.ErrorBackgroundColor    = "$bgcolor"
$pdata.WarningForegroundColor  = "Magenta"
$pdata.WarningBackgroundColor  = "$bgcolor"
$pdata.DebugForegroundColor    = "Cyan"
$pdata.DebugBackgroundColor    = "$bgcolor"
$pdata.VerboseForegroundColor  = "Yellow"
$pdata.VerboseBackgroundColor  = "$bgcolor"
$pdata.ProgressForegroundColor = "Cyan"
$pdata.ProgressBackgroundColor = "Blue"
}