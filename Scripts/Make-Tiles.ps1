<#
.Synopsis
   Create virtual tour tiles using Krpano-tools
.DESCRIPTION
    There are three options:
    1- 2 Levels: tilesize=902, 2 levels
    2- 3 Levels: tilesize=902, 3 levels
    2- Site Survey: tilesize=756, 2 levels
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
    Param($xmlfile, $custompath, $type)
    # Run Krpanotools
    Invoke-Expression "$krpath $krconfig $panopath" | Out-Null
    # Edit paths in the scene XML file
    if ($type -like "gforces") {
        # Replace 'scenes/$panoname' for %CURRENTXML%/scenes/tiles
        (Get-Content $xmlfile) |
        Foreach-Object {$_ -replace "scenes/$panoname", $custompath } |
        Set-Content $xmlfile
    } else {
        # Replace 'scenes/' for %SWFPATH%/scenes
        (Get-Content $xmlfile) |
        Foreach-Object {$_ -replace "scenes/", $custompath } |
        Set-Content $xmlfile
    }
}

function make-tiles {
    # Check panos directory is not empty
    if ($(Get-ChildItem .\.src\panos\) -eq $null) { Throw ".src\panos\ directory doesn't contain any folder" }
    foreach ( $tour in dir ".\.src\panos\" ) {
        Write-Verbose ('Tour: ' + $tour)
        # Check if the tour folder contains any jpg files
        if ($(Get-ChildItem .\.src\panos\$tour\*.jpg) -eq $null) { Throw ".src\panos\ doesn't contain any panoramas" } 
        foreach ( $panoname in $(dir ".\.src\panos\$tour\*.jpg").BaseName |
        # The first RegEx removes all the numbers and then sorts the list based on just the letters and punctuation.
        # The second RegEx removes all letters and punctuation leaving just the numbers.
        # Then casts the numbers to an Integer and sorts again.
        Sort-Object -Property {$_-replace '[\d]'},{$_-replace '[a-zA-Z\p{P}]'-as [int]} ) { 
            $panopath = Get-Item ".\.src\panos\$tour\$panoname.jpg"
            # Check if there is a folder containing the scene tiles AND it's corresponding xml file
            if((Test-Path -PathType Container ".\$tour\files\scenes\$panoname") -eq $True -and (Test-Path ".\$tour\files\scenes\$panoname.xml"))
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
                run-krpano -xmlfile $xmlfile -custompath $custompath -type "normal"
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


function make-twolevels {
    $krconfig = "-config=$krdir\krpano_conf\templates\tv_tiles_2_levels_all_devices.config"
    make-tiles
}

function make-threelevels {
    $krconfig = "-config=$krdir\krpano_conf\templates\tv_tiles_for_cars_ipad.config"
    make-tiles
}

function make-sitesurvey {
    $krconfig = "-config=$krdir\krpano_conf\templates\tv_tiles_2_levels_360sitesurvey.config"
    # Check panos directory is not empty
    if ($(Get-ChildItem .\.src\panos\) -eq $null) { Throw ".src\panos\ directory doesn't contain any folder" }
    foreach ( $tour in dir ".\.src\panos\" ) {
        # Check tour directory is not empty
        if ($(Get-ChildItem .\.src\panos\$tour) -eq $null) { Throw ".src\panos\ directory doesn't contain any folder" }
        Write-Verbose ('Tour: ' + $tour)
        foreach ( $area in dir ".\.src\panos\$tour\" ) { 
            # Check if the area folder contains any jpg files
            if ($(Get-ChildItem .\.src\panos\$tour\$area\*.jpg) -eq $null) { Throw ".src\panos\ doesn't contain any panoramas " } 
            Write-Verbose ('  Area: ' + $area)
            foreach ( $panoname in $(dir ".\.src\panos\$tour\$area\*.jpg").BaseName |
            # The first RegEx removes all the numbers and then sorts the list based on just the letters and punctuation.
            # The second RegEx removes all letters and punctuation leaving just the numbers.
            # Then casts the numbers to an Integer and sorts again.
            sort-object -Property {$_-replace '[\d]'},{$_-replace '[a-zA-Z\p{P}]'-as [int]} ) { 
                $panopath = Get-Item ".\.src\panos\$tour\$area\$panoname.jpg"
                if((Test-Path -PathType Container ".\files\sets\$tour\$area\$panoname") -eq $True -and (Test-Path ".\files\sets\$tour\$area\$panoname.xml"))
                {
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
                    run-krpano -xmlfile $xmlfile -custompath $custompath -type "sitesurvey"
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
function make-gforces {
    $krconfig = "-config=$krdir\krpano_conf\templates\tv_tiles_for_cars_ipad.config"
    # Check if the tour folder contains any jpg files
    if ($(Get-ChildItem .\.src\panos\*.jpg) -eq $null) { Throw ".src\panos\ doesn't contain any panoramas" }
    # Check that the panorama names has 3 underscores
    Get-ChildItem ".\.src\panos\*.jpg" |
    foreach {
        $underscores = ((($_.basename).ToString()).split("_")).count
        if($underscores -ne "4") { Throw "The file $($_.BaseName) doesn't have 4 underscores, it has $underscores. Plaese raname it. "}
    }
    # Delete any residual file or folder
    if(Test-Path ".\.src\panos\output") { Remove-Item -Recurse -Force ".\.src\panos\output" }
    Get-ChildItem ".\.src\panos\*.kro" | foreach { Remove-Item $_.Fullname }
    # Create tiles
    foreach ( $panoname in $(dir ".\.src\panos\*.jpg").BaseName |
    # The first RegEx removes all the numbers and then sorts the list based on just the letters and punctuation.
    # The second RegEx removes all letters and punctuation leaving just the numbers.
    # Then casts the numbers to an Integer and sorts again.
    Sort-Object -Property {$_-replace '[\d]'},{$_-replace '[a-zA-Z\p{P}]'-as [int]} ) {
        $panopath = Get-Item ".\.src\panos\$panoname.jpg"
        # Check if there is a folder containing the scene tiles AND it's corresponding xml file
        if((Test-Path -PathType Container ".\$panoname\files\scenes\tiles") -and (Test-Path ".\$panoname\files\scenes\scene.xml"))
        {
            Write-Verbose ('  [ OK ] ' + $panoname)
        }
        else
        {
            Write-Verbose ('  [    ] Making tiles for scene: ' + $panoname)
            check-folder -dir "$panoname"
            check-folder -dir "$panoname\files"
            check-folder -dir "$panoname\files\scenes"
            $outputfolder = "$($($panopath).Directory)\output"
            $scenesfolder = "$outputfolder\scenes\"
            $xmlfile = "$outputfolder\$panoname.xml"
            $custompath = "%SWFPATH%/../$panoname/files/scenes/tiles"
            run-krpano -xmlfile $xmlfile -custompath $custompath -type "gforces"
            # Move new tiles folders and xml files to tour\files\scenes\
            Move-Item ".\.src\panos\output\scenes\$panoname" ".\$panoname\files\scenes\tiles"
            Move-Item -Force ".\.src\panos\output\$panoname.xml" ".\$panoname\files\scenes\scene.xml"
            #Write-Verbose '         Done'
        }
    }
    # Delete output dir if exists
    if((Test-Path -PathType Container ".\.src\panos\output") -eq $true) {
        Remove-Item -Recurse .\.src\panos\output
    }
}

Clear-Host
# Krpano settings
$krdir = "E:\documents\software\virtual_tours\krpano"
$krpath = "$krdir\bin\krpanotools64.exe makepano"

if((Test-Path -PathType Container .src) -eq $false) { Throw ".src\ folder doesn't exist" }
if((Test-Path -PathType Container .\.src\panos) -eq $false) { Throw ".src\panos folder doesn't exist" }

# Choose config file    
$title = "Virtual tour type"
$message = "Choose which virtuar tour type you want to crate the tiles:"

$one = New-Object System.Management.Automation.Host.ChoiceDescription "&2 Levels", `
    "2 Levels"

$two = New-Object System.Management.Automation.Host.ChoiceDescription "&3 Levels", `
    "3 Levels"

$three = New-Object System.Management.Automation.Host.ChoiceDescription "&Site Survey", `
    "Site Servey"
$four = New-Object System.Management.Automation.Host.ChoiceDescription "&Gforces", `
    "Gforces"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($one, $two, $three, $four)

$result = $host.ui.PromptForChoice($title, $message, $options, 1) 
    
Switch( $result ){
    0{ make-twolevels }
    1{ make-threelevels }
    2{ make-sitesurvey }
    3{ make-gforces }
}
Write-Verbose "EOF"