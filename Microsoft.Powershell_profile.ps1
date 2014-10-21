# Set variable for PowerShell directory
$posh_dir = "$ENV:USERPROFILE\Documents\WindowsPowerShell"

#--------
# PATH
#--------
# Apps
$CCleaner = "$env:ProgramW6432\CCleaner\"
$Chrome = "${env:ProgramFiles(x86)}\Google\Chrome\Application\"
$CloudBerry = "$env:ProgramW6432\CloudBerryLab\CloudBerry Explorer for Amazon S3\"
$Defraggler = "$env:ProgramW6432\Defraggler\"
$Dropbox = "$env:APPDATA\Dropbox\bin\"
$Eclipse = "$env:ProgramW6432\eclipse\"
$Filezilla = "${env:ProgramFiles(x86)}\FileZilla FTP Client\"
$Firefox = "${env:ProgramFiles(x86)}\Mozilla Firefox\"
$IE = "$env:ProgramW6432\Internet Explorer\"
$Inkscape = "${env:ProgramFiles(x86)}\Inkscape\"
$Kitty = "$env:ProgramW6432\KiTTY\"
$Putty = "$env:ProgramW6432\PuTTY\"
# Posh
$ScriptsDir = "$(split-path $PROFILE)\Scripts\"
$GforcesDir = "$(split-path $PROFILE)\Scripts\gforces\"

$env:path += ";$CCleaner;$Chrome;$CloudBerry;$Defraggler;$Dropbox;$Eclipse;$Filezilla;$Firefox;$IE;$Inkscape;$Kitty;$Putty;$ScriptsDir;$GforcesDir"

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