function .. {Set-Location  ..}
function ... {Set-Location ../..}

function List-Directory {Get-ChildItem | Format-Table -AutoSize} 
function List-DirectoryAll {Get-ChildItem -Force | Format-Table -AutoSize}
function List-DirectoriesOnly {Get-ChildItem -Directory | Format-Table -AutoSize}
function List-FilesOnly {Get-ChildItem -File | Format-Table -AutoSize}
function List-DotFilesOnly {Get-ChildItem -File -Filter .* | Format-Table -AutoSize}
function New-File {New-Item -path $($args[0]) -ItemType File | Out-Null } 
function New-Directory  {New-Item -path $($args[0]) -ItemType Directory | Out-Null }


# APPLICATIONS
function pho   { & "$env:ProgramW6432\Adobe\Adobe Photoshop CS6 (64 Bit)\Photoshop.exe" $(Resolve-Path $args[0]) }
function irf   { & ${env:ProgramFiles(x86)}\IrfanView\i_view32.exe $(Resolve-Path $args[0]) }
function em    { Invoke-Expression "C:\msys64\mingw64\bin\runemacs.exe $args" }
function emc   { Invoke-Expression "C:\msys64\mingw64\bin\emacsclientw.exe -na C:\msys64\mingw64\bin\runemacs.exe $(Resolve-Path $args[0])" }
function emacs { Invoke-Expression "C:\msys64\mingw64\bin\runemacs.exe $args" }
function vim   { & ${env:ProgramFiles(x86)}\Vim\vim74\vim.exe --remote-silent  $args }
$deb_conf = 'startvm "Debian" --type gui'
function deb   { Invoke-Expression "C:\'Program Files'\Oracle\VirtualBox\VBoxManage.exe $deb_conf" }

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
function pageant {Start-Process $env:ProgramW6432\putty\pageant.exe $env:APPDATA\.ssh\UserKeys\github.ppk}
function Edit-GitBranchDescription {$(git branch --edit-description)}
function Get-GitBranchName {$(git rev-parse --abbrev-ref HEAD)}
function Get-GitBranchDescription {$(git config branch.$(git rev-parse --abbrev-ref HEAD).description)}

# MISC
function gforces-latest-cars {
<#
.DESCRIPTION
    Shows the last 15 jpg files added to the Gforces 'panos' directory
#>
    ls E:\virtual_tours\gforces\cars\.src\panos\*.jpg | 
    sort -Property LastWriteTime | 
    Select -Last 15 | 
    ft basename
}

function New-GforcesTourForLatestCars {
<#
.DESCRIPTION
    Runs New-GforcesTour for all the cars with Today's LastAccessTime
#>
    Get-ChildItem E:\virtual_tours\gforces\cars\.src\panos\*.jpg | 
    where {$_.LastAccessTime.Date -eq $(get-date).Date } | 
    New-GforcesTour -Verbose
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

function gt {
<#
.DESCRIPTION
    Temporary keybinding to test the module New-Gforces-Tour
#>
    [CmdletBinding()]
    Param()
    Import-Module New-GforcesTour
    Reset-module New-GforcesTour -Verbose
    Import-Module New-GforcesTour
    #cd C:\Users\Rafael\Downloads\gforces-tour
    cd E:\virtual_tours\gforces\cars
    #ll nl_opel* | New-GforcesTour -Verbose
}