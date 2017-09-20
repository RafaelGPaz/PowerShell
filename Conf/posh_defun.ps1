function .. {Set-Location  ..}
function ... {Set-Location ../..}

function List-DirectoryAll {Get-ChildItem -Force | Format-Table -AutoSize}
function List-DirectoriesOnly {Get-ChildItem -Directory | Format-Table -AutoSize}
function List-FilesOnly {Get-ChildItem -File | Format-Table -AutoSize}
function List-DotFilesOnly {Get-ChildItem -File -Filter .* | Format-Table -AutoSize}
function New-File {New-Item -path $($args[0]) -ItemType File | Out-Null }
function New-Directory  {New-Item -path $($args[0]) -ItemType Directory | Out-Null }
function New-Blog {pelican -s E:\websites\parallaxvirtualtours.co.uk\pelican\pelicanconf.py}
function Open-VSCode { & code.cmd -r $args }


# APPLICATIONS
function pho   { & "$env:ProgramW6432\Adobe\Adobe Photoshop CS6 (64 Bit)\Photoshop.exe" $(Resolve-Path $args[0]) }
function irf   { & ${env:ProgramFiles(x86)}\IrfanView\i_view32.exe $(Resolve-Path $args[0]) }
function em    { Invoke-Expression "C:\msys64\mingw64\bin\runemacs.exe $args" }
function emc   { Invoke-Expression "C:\msys64\mingw64\bin\emacsclientw.exe -na C:\msys64\mingw64\bin\runemacs.exe $(Resolve-Path $args[0])" }
function emacs { Invoke-Expression "C:\msys64\mingw64\bin\runemacs.exe $args" }
function vim   { & ${env:ProgramFiles(x86)}\Vim\vim74\vim.exe --remote-silent  $args }

# GIT
function ga { git add }
function gaa { git add --all }
function gapa { git add --patch }

function gb { git branch }
function gba { git branch -a }
function gbda { git branch --merged | command grep -vE "^(\*|\s*master\s*$)" | command xargs -n 1 git branch -d }
function gbl { git blame -b -w }
function gbnm { git branch --no-merged }
function gbr { git branch --remote }
function gbs { git bisect }
function gbsb { git bisect bad }
function gbsg { git bisect good }
function gbsr { git bisect reset }
function gbss { git bisect start }

function gc { git commit -v }
function gc! { git commit -v --amend }
function gca { git commit -v -a }
function gca! { git commit -v -a --amend }
function gcan! { git commit -v -a -s --no-edit --amend }
function gcam { git commit -a -m }
function gcb { git checkout -b }
function gcf { git config --list }
function gcl { git clone --recursive }
function gclean { git clean -fd }
#function gpristine { git reset --hard && git clean -dfx }
function gcm { git checkout master }
function gcmsg { git commit -m $args}
function gco { git checkout }
function gcount { git shortlog -sn }
function gcp { git cherry-pick }
function gcs { git commit -S }

function gd { git diff }
function gdca { git diff --cached }
function gdct { git describe --tags `git rev-list --tags --max-count=1` }
function gdt { git diff-tree --no-commit-id --name-only -r }

function gst { git status }

#function ga  {git add}
#function gap {git add -p}
#function gb  {git branch -a -v}
#function gch { if (!("$args")) { git checkout master } else { git checkout $args } }
#function gcl {git clone}
#function gd  {git diff}
#function gdc {git diff --cached}
#function gil {git log --pretty=oneline --date=short --decorate --graph --abbrev-commit $args }
#function gll {git log --pretty=oneline $args }
#function gco {git commit -m "$args"}
#function gam {git commit -am "$args"}
#function gus {git push}
#function gul {git pull}
#function gra {git remote add}
#function grr {git remote rm}
#function gs  {git status}

function Start-PageantGithub {Start-Process $env:ProgramW6432\putty\pageant.exe $env:HOME\.ssh\putty\github.ppk}
function Edit-GitBranchDescription {$(git branch --edit-description)}
function Get-GitBranchName {$(git rev-parse --abbrev-ref HEAD)}
function Get-GitBranchDescription {$(git config branch.$(git rev-parse --abbrev-ref HEAD).description)}

# MISC
function Find-GforcesLatestCars {
<#
.DESCRIPTION
    Shows the lastest jpg files added to the Gforces 'panos' directory
    Then I can pipelise them to "| select -last 5"
#>
    Get-ChildItem E:\virtual_tours\gforces\cars\*_*_*_* |
    sort -Property LastWriteTime
}

function Rename-OptizillaFiles {
<#
.DESCRIPTION
    Rename optimized files downloaded from Optizill.com removing the string "-min"
    Run the script inside th folder containing the images
#>
    [CmdletBinding()]

    $VerbosePreference = "Continue"

        Clear-Host
        Write-Verbose "Starting..."
        Get-ChildItem -Filter "*-min*" |
        Rename-Item -NewName { $_.Name -replace '-min',''} -Verbose
        Write-Verbose "EOF"
}