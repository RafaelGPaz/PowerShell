write-host -ForegroundColor Cyan "Backing up Life Image ........"
$batfile = [diagnostics.process]::Start("c:\Users\rafaelgp\work\documents\freefilesync\life_img.ffs_batch")
$batfile.WaitForExit()
write-host -ForegroundColor Green "Backing up Life Image [ done ]" 
write-host -ForegroundColor Cyan "Backing up Life Plus ........"
$batfile = [diagnostics.process]::Start("c:\Users\rafaelgp\work\documents\freefilesync\life_plus.ffs_batch")
$batfile.WaitForExit()
write-host -ForegroundColor Green "Backing up Life Plus [ done ]"
write-host -ForegroundColor Green "-- EOF --"