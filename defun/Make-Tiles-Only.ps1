# Krpano settings
$krversion = $(dir $krdir\krpano_tools -Exclude *linux*, *server* | sort -Descending)[0]
$krdir = "c:\Users\rafaelgp\work\documents\software\virtual_tours\krpano"
$krpath = "$krdir\krpano_tools\krpanotools-$krversion\kmakemultires.exe"
$krconfig = "-config=$krdir\krpano_conf\templates\tv_tiles_2_levels_all_devices.config"

function check-folder {
    Param($dir)
    # Create tour folder if it doesn't exists
    if((Test-Path -PathType Container $dir) -eq $False){
        New-Item $dir -type Directory | out-null
    }
}

function run-krpano {
    Param($panopath, $panoname)
    # Run Krpanotools
    Invoke-Expression "$krpath $krconfig $panopath"
    # Replace 'scenes/' for '%SWFPATH%/scenes/'
    $xmlfile = ".\output\$panoname.xml"
    (Get-Content $xmlfile) | 
    Foreach-Object {$_ -replace "scenes/", "%SWFPATH%/scenes/"} | 
    Set-Content $xmlfile
}

Clear-Host

foreach ( $panopath in dir ".\*.jpg" ) { 
    $panoname = [io.path]::GetFileNameWithoutExtension("$panopath")
    Write-Host -ForegroundColor Blue "[  info  ] Creating tiles for $panoname.jpg"
    run-krpano -panopath $panopath -panoname $panoname
}

Write-Host -ForegroundColor Green "[  DONE  ] ..."