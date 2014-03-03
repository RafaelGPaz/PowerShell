<#
.Synopsis
   Copy all the files inside 'allcars' directory apart from any folder named 'scenes'
.DESCRIPTION
   This facilitates update the gforces virtual tour, as I only have to upload
   to the server the content inside folder '.no_scanes' 
#>

$from = 'E:\virtual_tours\gforces\allcars'
$to = 'E:\virtual_tours\gforces\allcars\.no_scenes'
Remove-Item $to -Recurse -Force
New-Item -ItemType Directory $to | Out-Null
$exclude = @("")
$excludeMatch = @(".src", ".archives", "scenes", "*.ps1")
[regex] $excludeMatchRegEx = ‘(?i)‘ + (($excludeMatch |foreach {[regex]::escape($_)}) –join “|”) + ‘’
Get-ChildItem -Path $from -Recurse -Exclude $exclude |
 where { $excludeMatch -eq $null -or $_.FullName.Replace($from, "") -notmatch $excludeMatchRegEx} |
 Copy-Item -Destination {
  if ($_.PSIsContainer) {
   Join-Path $to $_.Parent.FullName.Substring($from.length)
  } else {
   Join-Path $to $_.FullName.Substring($from.length)
  }
 } -Force -Exclude $exclude -Verbose