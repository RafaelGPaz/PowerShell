# PowerShell appearance

# Set up a simple prompt (not in PowerGUI) showing the current directory
if ( $Host.Name -ne "PowerGUIScriptEditorHost" )
{
	function prompt {
	    Write-Host PS ($pwd) -nonewline -ForegroundColor Green
	    # Git Prompt
	    if($Global:GitPromptSettings.EnablePromptStatus) {
	        $Global:GitStatus = Get-GitStatus
	        Write-GitStatus $GitStatus
	    }
	    return "> "
	}
}

# Set Terminal colors
if ( $Host.Name -eq "ConsoleHost" )
{

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