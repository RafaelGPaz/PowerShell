# Usage: set-owner [user] [file]
$objUser = New-Object System.Security.Principal.NTAccount($args[0])
$objFile = Get-Acl $args[1]
$objFile.SetOwner($objUser)
Set-Acl -aclobject $objFile -path $args[1]