# This script is the equivalent to chmod u+wrk, it adds adds full permissions only to the user
# It's not the equivalent to chmod 700
$Acl = Get-Acl "$args"
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("rafaelgp","FullControl","Allow")
$Acl.SetAccessRule($Ar)
Set-Acl "$args" $Acl