function .. {Set-Location  ..}
function ... {Set-Location ../..}

function touch {New-Item "$args" -ItemType File | Out-Null} 
function mkdir {New-Item "$args" -ItemType Directory | Out-Null}

# APPLICATIONS
function pho   { & "$env:ProgramW6432\Adobe\Adobe Photoshop CS6 (64 Bit)\Photoshop.exe" $(Resolve-Path $args[0]) }
function irf   { & ${env:ProgramFiles(x86)}\IrfanView\i_view32.exe $(Resolve-Path $args[0]) }
function emacs { Start-Process -Verb runAs "C:\emacs\bin\runemacs.exe $args" } # Use this to open Emacs the first time. Then it will run as a server
function em    { Invoke-Expression "C:\emacs\bin\emacsclientw.exe -na C:\emacs\bin\runemacs.exe $(Resolve-Path $args[0])" }
function emq   { Start-Process -Verb runAs "C:\emacs\bin\emacs.exe --quick $args" }
function vim   { & ${env:ProgramFiles(x86)}\Vim\vim74\vim.exe --remote-silent  $args }

# GIT 
function ga  {git add}
function gap {git add -p}
function gb  {git branch -a -v}
function gch { if (!("$args")) { git checkout master } else { git checkout $args } }
function gcl {git clone}
function gd  {git diff}
function gdc {git diff --cached}
function gil {git log --pretty=oneline --date=short --decorate --graph --abbrev-commit $args }
function gll {git log --pretty=oneline $args }
function gco {git commit -m "$args"}
function gam {git commit -am "$args"}
function gus {git push}
function gul {git pull}
function gra {git remote add}
function grr {git remote rm}
function gs  {git status}
function pag {Start-Process $env:ProgramW6432\putty\pageant.exe $env:APPDATA\SSH\UserKeys\github.ppk}

# MISC
function gforces-latest-cars {
<#
.DESCRIPTION
    Shows the last 15 jpg files added to the Gforces 'panos' directory
#>
    ls E:\virtual_tours\gforces\allcars\.src\panos\*\*.jpg | 
    sort -Property LastWriteTime | 
    Select -Last 15 | 
    ft basename
}

function nt ([String]$TourName) {
<#
.DESCRIPTION
    Temporary keybinding to test the module New-Tour
#>
    Reset-module New-Tour
    . $profile
    cd C:\Users\Rafael\Downloads\test-make-tour
    #. C:\Users\Rafael\Documents\WindowsPowerShell\Modules\New-Tour\New-Tour.psm1
    New-Tour $TourName -Verbose 
}

function gt ([String]$TourName) {
<#
.DESCRIPTION
    Temporary keybinding to test the module New-Gforces-Tour
#>
    Import-Module New-GforcesTour
    Reset-module New-GforcesTour -Verbose
    Import-Module New-GforcesTour
    cd C:\Users\Rafael\Downloads\gforces-tour
    New-GforcesTour $TourName -Verbose
}