# Set variable for PowerShell directory
$posh_dir = "$ENV:USERPROFILE\Documents\WindowsPowerShell"

# Add defun directory to PowerShell path  
$env:Path = $env:Path + ";$posh_dir\defun\"

# Appearance
. "$posh_dir\conf\posh_appearance.ps1"
# Aliases
. "$posh_dir\conf\posh_aliases.ps1"
# Vendor
. "$posh_dir\vendor\posh-git\profile.example.ps1"