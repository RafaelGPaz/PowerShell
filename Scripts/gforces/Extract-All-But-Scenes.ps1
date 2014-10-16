<#
.DESCRIPTION
   Run the file Extract-All-But_scenes.ffs_batch (Free File Synch)
   It extracts all the files and folders inside the directory 'allcars', except the 'scenes' folders.
   It's saved in the directory '.no_scenes'
#>

write-verbose "Starting..."
$batfile = [diagnostics.process]::Start('C:\Users\Rafael\Documents\WindowsPowerShell\Scripts\gforces\Extract-All-But-Scenes.ffs_batch')
$batfile.WaitForExit()
Write-Verbose "Done"