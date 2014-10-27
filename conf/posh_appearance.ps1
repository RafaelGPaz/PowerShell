# PowerShell appearance

# Set up a simple prompt showing the current directory
function prompt {
    if ( $Host.Name -eq "ConsoleHost" ) {
        # Rename tab with the name of the current directory
        & "$env:ConEmuBaseDir\ConEmuC.exe" "/GUIMACRO", 'Rename(0,@"'$(get-item $PWD).BaseName'")' > $null
	    Write-Host PS ($pwd) -nonewline -ForegroundColor Cyan
    }
    if ( $Host.Name -eq "Windows PowerShell ISE Host" ) {
	    Write-Host PS ($pwd) -nonewline -ForegroundColor Magenta
    }
	# Git Prompt
	if($Global:GitPromptSettings.EnablePromptStatus) {
	    $Global:GitStatus = Get-GitStatus
	    Write-GitStatus $GitStatus
	}
	return " > "
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