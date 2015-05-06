<#
.DESCRIPTION
    Create a new tour.xml file merging all the XML files in the following directories:
    - files/content
    - files/include
    - files/scenes
#>
[CmdletBinding()]             
    Param (                        
        [Parameter(Mandatory=$False, 
            Position=0)]  
        [String]$Param1
        )#End Param
if(!(Test-Path -Path ".\files")) { Throw "There is no 'files' directory. Are you in the right directory?" }
$tourfile=".\files\tour.xml"
if(!(Test-Path -Path $tourfile)) { Throw "There is no 'tour.xml' file" }
rm $tourfile
New-Item -ItemType File -path $tourfile | Out-Null
# Head
set-content $tourfile  '<krpano version="1.18" showerrors="false"><krpano logkey="true" />'

# Plugins Directory
if(!(Test-Path -Path ".\files\plugins")) { rm $tourfile; Throw "There is no 'plugins' directory" 
}
$plugins = Get-ChildItem .\files\plugins\*.xml
Write-Output '===== Plugins ====='
Write-Output $plugins.Name 
ForEach ($file in $plugins) {Add-Content $tourfile $(Get-Content $file.FullName | 
where {$_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_ -notmatch '<?xml version' -and $_.trim() -ne "" } |
foreach {$_.ToString().TrimStart() }  
Out-String) }

# Content Directory
if(!(Test-Path -Path ".\files\content")) { rm $tourfile; Throw "There is no 'content' directory" 
}
$content = Get-ChildItem .\files\content\*.xml
if($content -eq $null) { rm $tourfile; Throw "There are no xml files in the 'content' directory" }
Write-Output '===== Content ====='
Write-Output $content.Name 
ForEach ($file in $content) {Add-Content $tourfile $(Get-Content $file.FullName | 
where {$_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_ -notmatch '<?xml version' -and $_.trim() -ne "" } |
foreach {$_.ToString().TrimStart() }  
Out-String) }

# Incude Directory
if(!(Test-Path -Path ".\files\include")) { rm $tourfile; Throw "There is no 'include' directory" }
$include = Get-ChildItem .\files\include\*\*.xml -Exclude 'coordfinder', 'editor_and_options'
if($include -eq $null) { rm $tourfile; Throw "There are no xml files in the 'include' directory" }
Write-Output '===== Include ====='
#Write-Output =  $include.Directory.Name
ForEach ($file in $include) {
Write-Output "$($file.Directory.Name)/index.xml"
Add-Content $tourfile $(Get-Content $file.FullName | 
where {$_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_ -notmatch '<?xml version' -and $_.trim() -ne "" } |
foreach {$_.ToString().TrimStart() }  
Out-String ) }

# Scenes Directory
if(!(Test-Path -Path ".\files\scenes")) { rm $tourfile; Throw "There is no 'scenes' directory" }
#$scenes = Get-ChildItem .\files\scenes\*.xml
$scenes = Get-ChildItem .\files\scenes\*.xml -Exclude info*.xml
if($scenes -eq $null) { rm $tourfile; Throw "There are no xml files in the 'scenes' directory" }
Write-Output '===== Scenes ====='
Write-Output $scenes.Name
ForEach ($file in $scenes) {
# Open scene tag
#Add-Content  $tourfile "<scene name=`"$($_.BaseName)`">";  
# scenes\scene#.xml
Add-Content $tourfile $(Get-Content $file.FullName |
where {$_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_.trim() -ne "" } |
#foreach {$_.ToString().TrimStart().Replace("url=`"scene","url=`"`%SWFPATH`%/scenes/scene") } |
foreach {$_.ToString().TrimStart() } |
Out-String);
#Add-Content  $tourfile "</scene>"; 
}
# Tail
Add-Content $tourfile  "</krpano>"
Write-Output "_EOF_"