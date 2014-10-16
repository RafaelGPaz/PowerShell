# Krpano settings
$krversion = "1.16.2"
$krdir = "c:\Users\rafaelgp\work\documents\software\virtual_tours\krpano"
$krpath = "$krdir\krpanotools-$krversion\kmakemultires.exe"
$krconfig = "-config=$krdir\krpano_conf\templates\tv_tiles_2_levels_all_devices.config"

foreach ( $tour in dir ".\.src\panos\" ) {
    foreach ( $panopath in dir ".\.src\panos\$tour\*.jpg" ) { 
    Invoke-Expression "$krpath $krconfig $panopath"
    $panoname = [io.path]::GetFileNameWithoutExtension("$panopath")
    $xmlfile = ".\.src\panos\$tour\output\$panoname.xml"
    # Replace 'scenes/' for '%SWFPATH%/scenes/'
    (Get-Content $xmlfile) | 
    Foreach-Object {$_ -replace "scenes/", "%SWFPATH%/scenes/"} | 
    Set-Content $xmlfile
    }
    Move-Item .\.src\panos\$tour\output\scenes\* .\$tour\files\scenes
    Move-Item .\.src\panos\$tour\output\*.xml .\$tour\files\scenes
    Remove-Item -Force .\.src\panos\$tour\output
}
