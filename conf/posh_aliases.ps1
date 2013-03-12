Set-Alias ll Get-ChildItem
Set-Alias cl Clear-Host
function wk {Set-Location $env:USERPROFILE\work}
function psh {Set-Location $ENV:USERPROFILE\Documents\WindowsPowerShell}
function hm {Set-Location $ENV:HOME}
function hp {Set-Location $ENV:HOMEPATH}
function dk {Set-Location $ENV:HOMEPATH\Desktop}
function dw {Set-Location $env:USERPROFILE\Downloads}
function dc {Set-Location $env:USERPROFILE\Documents}
function touch {New-Item "$args" -ItemType File}
function mkdir {New-Item "$args" -ItemType Directory}

# Aliases

function ga {git add}
function gap {git add -p}
function gb {git branch -a -v}
#function gc {if [ -z "$1" ]; then git checkout master; else git checkout $1; fi}
function gcl {git clone}
function gd {git diff}
function gdc {git diff --cached}
function gil {git log --pretty=format:"%h %ad | %s%d" --graph --date=short }
function gll {git log --pretty=oneline}
function gm {git commit -m}
function gma {git commit -am "$args"}
#function go {go_func}
function gp {git push}
function gpu {git pull}
#function gr {$win_home/bin/git_remove_after.sh}
function gra {git remote add}
function grr {git remote rm}
function gs {git status}
