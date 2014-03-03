# Set variable for PowerShell directory
$posh_dir = "$ENV:USERPROFILE\Documents\WindowsPowerShell"

# Add defun directory to PowerShell path  
$env:Path = $env:Path + ";$posh_dir\defun\"
$env:Path = $env:Path + ";$posh_dir\defun\newvt\"
$env:Path = $env:Path + ";$posh_dir\defun\newvt\lib\"

# Staff only for PoSH Console
if ( $Host.Name -eq "ConsoleHost" )
{
#PoshGit already imports it's own PowerTab module
Import-Module PowerTab
#Import-Module Posh-Git
Import-Module PsGet
Import-TabExpansionTheme Digital
}

#Staff only for PoSH ISE
if ( $Host.Name -eq "Windows PowerShell ISE Host")
{
Import-Module TabExpansion++
Import-Module PsGet
}

# Appearance
. "$posh_dir\conf\posh_appearance.ps1"
# Aliases
. "$posh_dir\conf\posh_aliases.ps1"
# Global Variables
. "$posh_dir\conf\posh_global_var.ps1"
# Vim
. "$posh_dir\conf\posh_vim.ps1"
# Emacs
. "$posh_dir\conf\posh_emacs.ps1"
