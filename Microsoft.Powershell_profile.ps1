# Set variable for PowerShell directory
$posh_dir = "$ENV:USERPROFILE\Documents\WindowsPowerShell"

#--------
# PATH
#--------
$pathArray = @(
    # Apps
    "$env:APPDATA\Dropbox\bin\",
    "$env:ProgramW6432\CCleaner\",
    "$env:ProgramW6432\CloudBerryLab\CloudBerry Explorer for Amazon S3\",
    "$env:ProgramW6432\Defraggler\",
    "$env:ProgramW6432\eclipse\",
    "$env:ProgramW6432\Internet Explorer\",
    "$env:ProgramW6432\KiTTY\",
    "$env:ProgramW6432\PuTTY\",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\",
    "${env:ProgramFiles(x86)}\FileZilla FTP Client\",
    "${env:ProgramFiles(x86)}\Mozilla Firefox\",
    "${env:ProgramFiles(x86)}\Inkscape\",
    "${env:ProgramFiles(x86)}\Mozilla Thunderbird",
    # Posh
    "$(split-path $PROFILE)\Scripts\",
    "$(split-path $PROFILE)\Scripts\gforces\")

foreach ($item in $pathArray) { $env:path += ';' + $item }

# Staff only for Terminal
if ( $Host.Name -eq "ConsoleHost" ) {
    Import-Module PSReadline
    Set-PSReadlineOption -EditMode Emacs
    Import-Module posh-git
}

#Staff only for ISE Console
#if ( $Host.Name -eq "Windows PowerShell ISE Host")
#{
#}

Import-Module TabExpansion++
Import-Module Go
Import-Module New-Tour
Import-Module Reset-Module
Import-Module z

# Start in my Home directory
cd C:\Users\Rafael

# Appearance
. "$(split-path $PROFILE)\Conf\posh_appearance.ps1"
# Aliases
. "$(split-path $PROFILE)\Conf\posh_aliases.ps1"
# Funtions
. "$(split-path $PROFILE)\Conf\posh_defun.ps1"