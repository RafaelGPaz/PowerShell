# Krpano settings
$krdir = "E:\documents\software\virtual_tours\krpano"
$krversion = $(dir $krdir\krpano_tools -Exclude *linux*, *server* | sort -Descending)[0]
$krpath = "$krversion\kmakemultires.exe"
$krconfig = "-config=$krdir\krpano_conf\templates\tv_tiles_2_levels_360sitesurvey.config"

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
    #Invoke-Expression "$krpath $krconfig $panopath"
    #$krpath
    #$krconfig
    #$panopath
    # Add '%SWFPATH%/scenes/'
    break
    (Get-Content "$(($tour).FullName)\panos\$(($panopath).BaseName).xml") |
    Foreach-Object {$_ -replace 'url="', 'url="%SWFPATH%/scenes/'} | 
    Set-Content "$(($tour).FullName)\panos\$(($panopath).BaseName).xml"
}

Clear-Host

foreach ($tour in (dir ".\.src\panos\")) {
    Write-Verbose "Tour: $tour" -Verbose
    check-folder -dir "$tour"
    foreach ( $panopath in (dir $tour.FullName -Recurse -Filter *.jpg)) { 
        $panopath
        # Check if there is a folder containing the scene tiles
        if((Test-Path -PathType Container "$tour\$($panopath).BaseName") -eq $True)
        {
            Write-Verbose "Scene: $(($panopath).BaseName) is OK" -Verbose
        }
        else 
        {    
            Write-Verbose "Making tiles for scene: $(($panopath).Basename)" -Verbose
            check-folder -dir "$tour\$(($tour).BaseName)"
            run-krpano -panopath $($panopath.FullName) -panoname $(($panopath).BaseName)
            break
            # Move new tiles folders and xml files to tour\files\scenes\
            Move-Item "$(($tour).FullName)\panos\$(($panopath).BaseName)" "$tour"
            #Move-Item "$(($tour).FullName)\panos\$(($panopath).BaseName)" ".\files\sets\$(($tour).BaseName)\"
            #Move-Item "$(($tour).FullName)\panos\$(($panopath).BaseName).xml" ".\files\sets\$(($tour).BaseName)\"
        }
    # Delete panos dir if exists
    if((Test-Path -PathType Container "$(($tour).FullName)\panos") -eq $true) {
        Remove-Item -Recurse "$(($tour).FullName)\panos\"
    }
    }
}
Write-Verbose "[ Done ]" -Verbose
