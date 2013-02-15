# PowerShell appearance

# Set up a simple prompt, adding the git prompt parts inside git repos
function prompt {
    Write-Host($pwd) -nonewline -ForegroundColor Yellow
    # Git Prompt
    if($Global:GitPromptSettings.EnablePromptStatus) {
        $Global:GitStatus = Get-GitStatus
        Write-GitStatus $GitStatus
    }
    return "> "
}

if ( $Host.Name -eq "ConsoleHost" )
{
$rui = (Get-Host).UI.RawUI
$rui.BackgroundColor = "DarkBlue"
$rui.ForegroundColor = "White"

$bgcolor = "DarkBlue"
$pdata = (Get-Host).PrivateData
$pdata.ErrorForegroundColor    = "Green"
$pdata.ErrorBackgroundColor    = "$bgcolor"
$pdata.WarningForegroundColor  = "DarkRed"
$pdata.WarningBackgroundColor  = "$bgcolor"
$pdata.DebugForegroundColor    = "Cyan"
$pdata.DebugBackgroundColor    = "$bgcolor"
$pdata.VerboseForegroundColor  = "Yellow"
$pdata.VerboseBackgroundColor  = "$bgcolor"
$pdata.ProgressForegroundColor = "Yellow"
$pdata.ProgressBackgroundColor = "Blue"
}