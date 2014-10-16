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
    $xmlfile = ".\.src\panos\$tour\output\$panoname.xml"
    (Get-Content $xmlfile) | 
    Foreach-Object {$_ -replace "scenes/", "%SWFPATH%/scenes/"} | 
    Set-Content $xmlfile
}

Clear-Host

foreach ( $tour in dir ".\.src\panos\" ) {
    Write-Host -ForegroundColor Cyan "[ info ] Tour: $tour"
    foreach ( $panopath in dir ".\.src\panos\$tour\*.jpg" ) { 
        # Check if there is a folder containing the scene tiles
        $panoname = [io.path]::GetFileNameWithoutExtension("$panopath")
        if((Test-Path -PathType Container "$tour\files\scenes\$panoname") -eq $True){
            Write-Host -ForegroundColor Green "[  ok  ] Scene: $panoname"
            }
        else {    
            Write-Host -ForegroundColor Cyan "[ info ] Making tiles for scene: $panoname"
            check-folder -dir "$tour"
            check-folder -dir "$tour\files"
            check-folder -dir "$tour\files\scenes"
            #exit
            run-krpano -panopath $panopath -panoname $panoname
            # Move new tiles folders and xml files to tour\files\scenes\
            Move-Item ".\.src\panos\$tour\output\scenes\$panoname" ".\$tour\files\scenes\"
            Move-Item ".\.src\panos\$tour\output\$panoname.xml" ".\$tour\files\scenes\"
            Write-Host -ForegroundColor Green "[  ok  ] Tiles done"
        }
        #exit
    # Delete output dir if exists
    if((Test-Path -PathType Container ".\.src\panos\$tour\output") -eq $true) {
        Remove-Item -Recurse .\.src\panos\$tour\output
    }
    }
}
Write-Host -ForegroundColor Green "[  DONE  ] ..."