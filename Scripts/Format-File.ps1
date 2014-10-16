<#
.Synopsis
Use Emacs to auto format a file
.DESCRIPTION
Most of the editors auto format option sucks. Emacs seems to be the only one that makes a decent job.
This script uses emacs to auto format a given file.
.EXAMPLE
Example of how to use this cmdlet
.EXAMPLE
Another example of how to use this cmdlet
#>

[CmdletBinding()]
[OutputType([int])]
Param
(
# Param1 help description
[Parameter(Mandatory=$true,
ValueFromPipelineByPropertyName=$true,
Position=0)]
$Param1
)

$DebugPreference = "Continue"
$ErrorActionPreference= 'silentlycontinue'

$emacs_dir = 'C:\emacs\bin\emacs.exe'
$script_dir = 'C:\Users\rafaelgp\Documents\WindowsPowerShell\defun\emacs-format-file.el'
$file_path = Get-Item $Param1
$emacs_expression = $emacs_dir + ' --batch ' + ($file_path).FullName + ' -l ' + $script_dir + ' -f emacs-format-function'

function Start-Script {
Invoke-Expression $emacs_expression | Out-Null
#Write-Host $emacs_expression
}

Start-Script $Param1

#C:\emacs\bin\emacs.exe -batch .\scene1.html -l C:\Users\rafaelgp\Documents\WindowsPowerShell\defun\emacs-format-file.el -f emacs-format-function