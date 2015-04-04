dir -recurse | where {-Not $_.PsIscontainer -AND $_.name -match "-"} | foreach {
$New=$_.name.Replace("-","_")
Rename-Item -path $_.Fullname -newname $New -passthru
}