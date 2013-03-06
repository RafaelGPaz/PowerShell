# Set variable for PowerShell directory
$posh_dir = "$ENV:USERPROFILE\Documents\WindowsPowerShell"

# Add defun directory to PowerShell path  
$env:Path = $env:Path + ";$posh_dir\defun\"

# Staff only for PoSH Console
if ( $Host.Name -eq "ConsoleHost" )
{
# Import PowerTab module before PoshGit
Import-Module PowerTab
Import-Module PoshGit
}

#Staff only for PoSH ISE
if ( $Host.Name -eq "Windows PowerShell ISE Host")
{
Import-Module TabExpansion++
}


# Appearance
. "$posh_dir\conf\posh_appearance.ps1"
#. "$posh_dir\conf\posh_git.ps1"
# Aliases
. "$posh_dir\conf\posh_aliases.ps1"

