# Set variable for PowerShell directory
$posh_dir = "$ENV:USERPROFILE\Documents\WindowsPowerShell"

# Add defun directory to PowerShell path  
$env:Path = $env:Path + ";$posh_dir\defun\"

Import-Module $posh_dir\modules\posh_git

# Appearance
. "$posh_dir\conf\posh_appearance.ps1"
# Aliases
. "$posh_dir\conf\posh_aliases.ps1"

