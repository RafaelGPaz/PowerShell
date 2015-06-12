<#
.Synopsis
   Update Spacemacs
#>

[cmdletbinding()]

$VerbosePreference = "Continue"
# Stop if there is any error
$ErrorActionPreference = "Stop"


Clear-Host
cd 'C:\users\Rafael\AppData\Roaming\.emacs.d'
Write-Verbose "git pull --rebase"
git pull --rebase
Write-Verbose "git submodule sync"
git submodule sync
Write-Verbose "git submodule update"
git submodule update

Write-Verbose "EOF" -Verbose