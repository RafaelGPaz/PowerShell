# Start Emacs
# Function emacs { & C:\emacs\bin\runemacs.exe -q -l C:\Users\rafaelgp\AppData\Roaming\.emacs\init.el $1 }

# Edit PowerShell profile
#Function Edit-Posh-Profile
# {
# emacs "-file C:\Users\rafaelgp\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps"
# }

# Edit Vim profile
# Function Edit-Emacs-Profile
# {
# emacs "C:\Users\rafaelgp\AppData\Roaming\.emacs\init.el"
# }

# Function to enable pipe into Emacs
# Example: gci *.ps1 | em
# Function em ()
# {
# $filepaths = $input | Get-Item | % { $_.fullname }
# emacs $filepaths
# }

function Set-ActiveWindow($handle) {
        $user32::SetActiveWindow($handle)
}

function Set-Focus($handle) {
        $user32::SetFocus($handle)
}

function Set-ForegroundWindow($handle) {
        $user32::SetForegroundWindow($handle)
}

function Show-Window($handle, $cmd) {
        $user32::ShowWindow($handle, $cmd)
}

function Send-WindowToFront($windowHandle) {
        $currentWindowHandle = Get-ForegroundWindow
        $currentWindowThread = Get-WindowThreadProcessId $currentWindowHandle
        # $currentWindowThread = Get-CurrentThreadId
        $newWindowThread = Get-WindowThreadProcessId $windowHandle
        Attach-ThreadInput $currentWindowThread $newWindowThread $true
        Bring-WindowToTop $windowHandle
        Show-Window $windowHandle 10
        Set-ActiveWindow $windowHandle
        Set-ForegroundWindow $windowHandle
        Set-Focus $windowHandle
        Attach-ThreadInput $currentWindowThread $newWindowThread $false
}

# Useful functions:
function Safe-Resolve-Path($path) {
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
                $path)
}

# Other aliases:
function emacs($filename) {
        $emacsDirectory = 'C:\emacs\bin'
        $emacs = Join-Path $emacsDirectory 'runemacs.exe'
        $emacsClient = Join-Path $emacsDirectory 'emacsclientw.exe'
        $serverFile = Safe-Resolve-Path '~\.emacs\server\server'
        # If parameter is not defined, just find emacs window and send it to front:
        if (!$filename) {
                write-host "No filename given"
                if (Test-Path $serverFile) {
                        $emacsPid = (Get-Content $serverFile)[0].Split(' ')[1]
                        $process = Get-Process -Id $emacsPid
                        $windowHandle = $process.MainWindowHandle
                        Send-WindowToFront $windowHandle
                } else {
                        & $emacs
                }
        } else {
                write-host "Filename: $filename"
                & $emacsClient -f $serverFile -a $emacs (Safe-Resolve-Path $filename)
        }
}