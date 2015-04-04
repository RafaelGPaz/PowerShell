# Open CCleaner Registry tab
$cpath = "C:\'Program Files'\CCleaner\CCleaner64.exe"
Invoke-Expression "$cpath /REGISTRY"
write-host -ForegroundColor Green "Open CCleaner - Registry"