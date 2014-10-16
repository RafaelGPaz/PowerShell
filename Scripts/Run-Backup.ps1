write-verbose "Backing up Home img ..." -Verbose
$batfile = [diagnostics.process]::Start("E:\documents\freefilesync\home_img.ffs_batch")
$batfile.WaitForExit()
write-verbose "Backing up Home plus ..." -Verbose
$batfile = [diagnostics.process]::Start("E:\documents\freefilesync\home_plus.ffs_batch")
$batfile.WaitForExit()
write-verbose "Backing up Work img ..." -Verbose
$batfile = [diagnostics.process]::Start("E:\documents\freefilesync\work_img.ffs_batch")
$batfile.WaitForExit()
write-verbose "Backing up Work plus ..." -Verbose
$batfile = [diagnostics.process]::Start("E:\documents\freefilesync\work_plus.ffs_batch")
$batfile.WaitForExit()
#write-verbose "Backing up Dropbox ..." -Verbose
#$batfile = [diagnostics.process]::Start("E:\documents\freefilesync\dropbox.ffs_batch")
#$batfile.WaitForExit()
write-verbose "[i] All backed up" -Verbose