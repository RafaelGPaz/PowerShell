# PowerShell appearance

function Prompt
{
    $promptString = "PS " + $(Get-Location) + ">"
    # Custom color for Windows console
    #if ( $Host.Name -eq "ConsoleHost" )
    #{
        Write-Host $promptString -NoNewline -ForegroundColor Yellow
    #}
    # Default color for the rest
    #else
    #{
    #    Write-Host $promptString -NoNewline -ForegroundColor Yellow
    #}
    return " "
}

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
if ( $Host.Name -eq "ConsoleHost" )
{
$pdata.ProgressForegroundColor = "Yellow"
$pdata.ProgressBackgroundColor = "Blue"
}