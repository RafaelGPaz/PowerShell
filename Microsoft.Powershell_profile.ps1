# Set variable for PowerShell directory
$posh_dir = "$ENV:USERPROFILE\Documents\WindowsPowerShell"

# Add defun directory to PowerShell path  
$env:Path = $env:Path + ";$posh_dir\defun\"

# Import PowerTab module before PoshGit
Import-Module PowerTab
Import-Module PoshGit

# Appearance
. "$posh_dir\conf\posh_appearance.ps1"
#. "$posh_dir\conf\posh_git.ps1"
# Aliases
. "$posh_dir\conf\posh_aliases.ps1"

