<#
.Synopsis
   Create virtual tour tiles using Krpano-tools
.DESCRIPTION
    Create virtual tour tiles using Krpano-tools. Depending on the project there are two options:
    1- all: 2 levels, tilesize=902
    2- sitesurvey: 2 levels, tilesize=756
.EXAMPLE
   Run from the same directory containing the folder '.src'
#>

[cmdletbinding()]

Param ()

$VerbosePreference = "Continue"

function check-folder {
    Param($dir)
    # Create tour folder if it doesn't exists
    if((Test-Path -PathType Container $dir) -eq $False){
        New-Item $dir -type Directory | out-null
    }
}

function run-krpano {
    Param($xmlfile, $custompath)
    # Run Krpanotools
    Invoke-Expression "$krpath $krconfig $panopath" | Out-Null
    # Replace 'scenes/' for my custom path
        (Get-Content $xmlfile) | 
        Foreach-Object {$_ -replace "scenes/", $custompath } | 
        Set-Content $xmlfile
}

function make-normaltiles {
    $krconfig = "-config=$krdir\krpano_conf\templates\tv_tiles_2_levels_all_devices.config"
    # Check panos directory is not empty
    if ($(Get-ChildItem .\.src\panos\) -eq $null) { Write-Warning ".src\panos\ directory doesn't contain any folder "; break  }
    foreach ( $tour in dir ".\.src\panos\" ) {
        Write-Verbose ('Tour: ' + $tour)
        # Check if the tour folder contains any jpg files
        if ($(Get-ChildItem .\.src\panos\$tour\*.jpg) -eq $null) { Write-Warning ".src\panos\ doesn't contain any panoramas "; break } 
        foreach ( $panoname in $(dir ".\.src\panos\$tour\*.jpg").BaseName |
        # The first RegEx removes all the numbers and then sorts the list based on just the letters and punctuation.
        # The second RegEx removes all letters and punctuation leaving just the numbers
        # Then casts the numbers to an Integer and sorts again.
        sort-object -Property {$_-replace '[\d]'},{$_-replace '[a-zA-Z\p{P}]'-as [int]} ) { 
            $panopath = Get-Item ".\.src\panos\$tour\$panoname.jpg"
            # Check if there is a folder containing the scene tiles
            #$panoname = [io.path]::GetFileNameWithoutExtension("$panopath")
            if((Test-Path -PathType Container ".\$tour\files\scenes\$panoname") -eq $True)
            {
                Write-Verbose ('  [ OK ] ' + $panoname)
            }
            else 
            {    
                Write-Verbose ('  -----> Making tiles for scene: ' + $panoname)
                check-folder -dir "$tour"
                check-folder -dir "$tour\files"
                check-folder -dir "$tour\files\scenes"
                $outputfolder = "$($($panopath).Directory)\output"
                $scenesfolder = "$outputfolder\scenes\"
                $xmlfile = "$outputfolder\$panoname.xml"
                $custompath = '%SWFPATH%/scenes/'
                run-krpano -xmlfile $xmlfile -custompath $custompath
                # Move new tiles folders and xml files to tour\files\scenes\
                Move-Item ".\.src\panos\$tour\output\scenes\$panoname" ".\$tour\files\scenes\"
                Move-Item -Force ".\.src\panos\$tour\output\$panoname.xml" ".\$tour\files\scenes\"
                Write-Verbose '  Tiles Done'
                # Delete output dir if exists
                if((Test-Path -PathType Container ".\.src\panos\$tour\output") -eq $true) {
                    Remove-Item -Recurse .\.src\panos\$tour\output
                }
            }
        }
    }
}

function make-sitesurveyties {
    $krconfig = "-config=$krdir\krpano_conf\templates\tv_tiles_2_levels_360sitesurvey.config"
    # Check panos directory is not empty
    if ($(Get-ChildItem .\.src\panos\) -eq $null) { Write-Warning ".src\panos\ directory doesn't contain any folder "; break  }
    foreach ( $tour in dir ".\.src\panos\" ) {
        # Check tour directory is not empty
        if ($(Get-ChildItem .\.src\panos\$tour) -eq $null) { Write-Warning ".src\panos\ directory doesn't contain any folder "; break  }
        Write-Verbose ('Tour: ' + $tour)
        foreach ( $area in dir ".\.src\panos\$tour\" ) { 
            # Check if the area folder contains any jpg files
            if ($(Get-ChildItem .\.src\panos\$tour\$area\*.jpg) -eq $null) { Write-Warning ".src\panos\ doesn't contain any panoramas "; break } 
            Write-Verbose ('  Area: ' + $area)
            foreach ( $panoname in $(dir ".\.src\panos\$tour\$area\*.jpg").BaseName |
            # The first RegEx removes all the numbers and then sorts the list based on just the letters and punctuation.
            # The second RegEx removes all letters and punctuation leaving just the numbers
            # Then casts the numbers to an Integer and sorts again.
            sort-object -Property {$_-replace '[\d]'},{$_-replace '[a-zA-Z\p{P}]'-as [int]} ) { 
                $panopath = Get-Item ".\.src\panos\$tour\$area\$panoname.jpg"
                if((Test-Path -PathType Container "files\sets\$tour\$area\$panoname") -eq $True){
                    write-Verbose ('    [ OK ] ' + $panoname)
                }
                else 
                {
                    Write-Verbose ('  -----> Making tiles for scene: ' + $panoname)
                    check-folder -dir "files"
                    check-folder -dir "files\sets"
                    check-folder -dir "files\sets\$tour"
                    check-folder -dir "files\sets\$tour\$area"
                    $outputfolder = "$($($panopath).Directory)\output"
                    $scenesfolder = "$outputfolder\scenes\"
                    $xmlfile = "$outputfolder\$panoname.xml"
                    $custompath = '%SWFPATH%/../../files/sets/'
                    run-krpano -xmlfile $xmlfile -custompath $custompath
                    Move-Item "$outputfolder\scenes\$panoname" ".\files\sets\$tour\$area\" 
                    Move-Item -Force "$xmlfile" ".\files\sets\$tour\$area\" 
                    Write-Verbose '  Tiles Done'
                    # Delete output dir if exists
                    if((Test-Path -PathType Container $outputfolder) -eq $true) {
                        Remove-Item -Recurse $outputfolder 
                    }
                }
            } 
        } 
    }
}

Clear-Host
# Krpano settings
$krdir = "E:\documents\software\virtual_tours\krpano"
$krpath = "$krdir\bin\krpanotools64.exe makepano"

if((Test-Path -PathType Container .src) -eq $false) { Write-Warning ".src\ folder doesn't exist "; break }
if((Test-Path -PathType Container .\.src\panos) -eq $false) { Write-Warning ".src\panos folder doesn't exist "; break }

# Choose config file    
$title = "Virtual tour type"
$message = "Choose which virtuar tour type you want to crate the tiles:"

$one = New-Object System.Management.Automation.Host.ChoiceDescription "&Normal", `
    "Normal"

$two = New-Object System.Management.Automation.Host.ChoiceDescription "&Site Survey", `
    "Site Survey"

$options = [System.Management.Automation.Host.ChoiceDescription[]]($one, $two)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 
    
Switch( $result ){
    0{ make-normaltiles }
    1{ make-sitesurveyties }
}
Write-Verbose "EOF"