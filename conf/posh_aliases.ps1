Set-Alias ll Get-ChildItem
Set-Alias la Get-ChildItem -Force
Set-Alias cc Clear-Host
Set-Alias sls Select-String
Set-Alias halt Stop-Computer
Set-Alias pro Reload-Profile

function .. {Set-Location  ..}
function ... {Set-Location ../..}
function vt {Set-Location $vt}  # Virtual Tours
function jb {Set-Location $jb}  # Jobs
function wb {Set-Location $wb}  # Websites
function wp {Set-Location $wp}  # Windows Powershell
function dk {Set-Location $dk}  # Desktop
function dw {Set-Location $dw}  # Downloads
function dc {Set-Location $dc}  # Documents
function bx {Set-Location $bx}  # DropBox
function hm {Set-Location $hm}  # Home
function ss {Set-Location $ss}  # 360 Site Survey 
function bin {Set-Location $vt\.archives\bin}  # bin directory 

function touch {New-Item "$args" -ItemType File | Out-Null} 
function mkdir {New-Item "$args" -ItemType Directory | Out-Null}

# Applications
function bridge       {Start-Process 'C:\Program Files (x86)\Adobe\Adobe Bridge CS4\Bridge.exe' $args }
function ccleaner     {Start-Process 'C:\Program Files\CCleaner\CCleaner64.exe' $args }
function chrome       {Param ([Parameter(Mandatory=$false)]$Param) Start-Process 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' $Param }
function defraggler   {Start-Process 'C:\Program Files\Defraggler\Defraggler64.exe' $args }
function filezilla    {Start-Process 'C:\Program Files (x86)\FileZilla FTP Client\filezilla.exe' $args }
function firefox      {Start-Process 'C:\Program Files (x86)\Mozilla Firefox\firefox.exe' $args }
function ie           {Start-Process 'C:\Program Files\Internet Explorer\iexplore.exe' $args }
function inkscape     {Start-Process 'C:\Program Files (x86)\Inkscape\inkscape.exe' $args }
function photoshop    {Start-Process 'C:\Program Files\Adobe\Adobe Photoshop CS4 (64 Bit)\Photoshop.exe' $args }
function thunderbirth {Start-Process 'C:\Program Files (x86)\Mozilla Thunderbird\thunderbird.exe' }
function winscp       {Start-Process 'C:\Program Files (x86)\WinSCP\WinSCP.exe' $args }
function dbox         {Invoke-Item "$env:APPDATA\Dropbox\bin\Dropbox.exe"}
function posh         {Start-Process 'powershell.exe' $args}
function winscp       {& "C:\Program Files (x86)\WinSCP\WinSCP.exe" $args}
function phs          {$file = $(Get-Item $args).FullName; & 'C:\Program Files (x86)\Adobe\Adobe Photoshop CS4\Photoshop.exe' $file}
function sub          {Param ([Parameter(Mandatory=$false)]$openFile="$Params -new_console:s75V") Start-Process 'C:\Program Files\cmder\vendor\Sublime Text 3\sublime_text.exe' $openFile}
function ecl          {Start-Process 'C:\Program Files\eclipse\eclipse.exe' $args}

# Git 
function ga  {git add}
function gap {git add -p}
function gb  {git branch -a -v}
#function gc {if [ -z "$1" ]; then git checkout master; else git checkout $1; fi}
function gcl {git clone}
function gd  {git diff}
function gdc {git diff --cached}
function gil {git log --pretty=format:"%h %ad | %s%d" --graph --date=short }
function gll {git log --pretty=oneline}
function gm  {git commit -m}
function gma {git commit -am "$args"}
#function go {go_func}
function gp  {git push}
function gpu {git pull}
#function gr {$win_home/bin/git_remove_after.sh}
function gra {git remote add}
function grr {git remote rm}
function gs  {git status}
