<#
.DESCRIPTION
    Required:
    - .src/ directory
    - .src/panos/*.jpg files
    - .src/config.xml file
    Run the script from the root manufactures folder (ex: gmc_manufacturer/) like this:
        gi .\gmc_sierra_2015\ | New-ManufacturerTour.ps1 -Verbose
    Files that will be created:
    - index.html and devel.html in the root directory
    - index.html and devel.html in the model directory
    - tour.xml
.PARAMETER TourName
    The Name of the Tour to build. Pass it through a pipe line.
.EXAMPLE
    gi .\gmc_sierra_2015\ | New-ManufacturerTour.ps1 -Verbose
#>
[CmdletBinding()]
Param (
[Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$true)]
    $TourName
    )
Begin {
    #$DebugPreference = "Continue"
    # Stop if there is any error
    $ErrorActionPreference = "Stop"
    $krVersion = "1.18"
    # All the files are relative to this script path
    $dir = $pwd
    $config = "$dir\.src\config.xml"
    if(!(Test-Path -Path "$dir\.src")) { Throw "There is no '.src' directory. Are you in the right directory?" }
    if (!(Test-Path $config)) { Throw "Where is config.xml?" }
    # Source config.xml
    [xml]$configXml = Get-Content $config
    # Array containing all the cars to be ranamed
    $ignoreTour = $configXml.tour.ignore.car
    foreach ($ignoreCar in $ignoreTour) {
        [Array]$ignoreArray += $ignoreCar.id
    }
    # Array containing all the cars to be ranamed
    $ignoreTour = $configXml.tour.rename.car
    foreach ($ignoreCar in $ignoreTour) {
        [Array]$ignoreArray += $ignoreCar.id
    }
    Write-Verbose "-------------------- Checking --------------------"
    $carNumber = 0
    foreach ( $brand in $configXml.tour.brand ) {
        foreach ($car in $brand.car) {
            $carNumber = $carNumber + 1
            # Skip checking ignored cars
            if ($ignoreArray -notcontains $car.id) {
                # Check that there is a panorama for each car in config.xml
                if(!(Test-Path .\.src\panos\$($car.id).jpg )) { Throw "Pano .src\panos\$($car.id).jpg NOT FOUND." }
                # Check that every car has tites and scene.xml
                if(!(Test-Path .\$($car.id)\files )) { Throw "Folder .\$($car.id)\files NOT FOUND. Did you create the tiles correctly?" }
                if(!(Test-Path .\$($car.id)\files\scenes )) { Throw "Folder .\$($car.id)\files\scenes NOT FOUND. Did you create the tiles correctly?" }
                if(!(Test-Path .\$($car.id)\files\scenes\tiles )) { Throw "Folder .\$($car.id)\files\scenes\tiles NOT FOUND. Did you create the tiles correctly?" }
                if(!(Test-Path .\$($car.id)\files\scenes\scene.xml )) { Throw "File .\$($car.id)\files\scenes\scene.xml NOT FOUND. Did you create the tiles correctly?" }
            }
        }
    }
    # Check there are no folders which don't belong to an existing panorama
    Get-ChildItem . -Exclude .custom, .src, .no_scenes, brands, shared -Directory |
    foreach {
        $carID = $($_.BaseName)
        $carFolder = ".src/panos/$carID.jpg"
        # Skip checking ignored cars
        if ($ignoreArray -notcontains $carID) {
            if(!(Test-Path $($carFolder))) {
                # Cars in the rename section aren't obsolete
                if ($renameToArray -notcontains $carID) {
                    throw "The following folder is obsolete: $($_.FullName)"
                }
            }
        }
    }
    Write-Verbose ">> Cars:      $carNumber"
    Write-Verbose "-------------------- Cars --------------------"

    function Add-ManufacturerHtmlFiles {
        Write-Debug "   > HTML files" -Verbose
        if ( Test-Path $dir\$tour\index.html ) {
            Remove-Item $dir\$tour\index.html -Force
            #Write-Debug "     Delete file $dir\$tour\index.html"
        }
        if ( Test-Path $dir\$tour\devel.html ) {
            Remove-Item $dir\$tour\devel.html -Force
            #Write-Debug "     Delete file $dir\$tour\devel.html"
        }
        # index.html
        $template_content = Get-Content $dir\.src\html\scene_template.html
        $template_content |
        foreach { ($_).replace('SERVERNAME',$configXML.tour.url) } |
        foreach { ($_).replace('SCENENAME',$tour) } |
        Out-File -Encoding utf8 $dir\$tour\index.html
        # devel.xml
        $template_content |
        foreach { ($_).replace('SERVERNAME','..') } |
        foreach { ($_).replace('SCENENAME',$tour) } |
        foreach { ($_).replace('tour.xml','devel.xml') } |
        Out-File -Encoding utf8 $dir\$tour\devel.html
    }
    function Add-ManufacturerContent {
        # index includes: coord.xml and panolist.xml
        Write-Debug "   > content/index.xml file"
        $contentFile = "$dir\$tour\files\content\index.xml"
        New-Item -ItemType File $contentFile -Force | Out-Null
        Set-Content -Force $contentFile '<krpano>'
        Add-Content $contentFile ('    <action name="movecamera_' + $car.id + '">movecamera(' +  $car.h +  ',' + $car.v + ');</action>')
        Add-Content $contentFile ('    <layer name="panolist" keep="true"><pano name="' + $car.id + '" scene="' + $car.name + '" title="' + $car.name + '" /></layer>')
        Add-Content $contentFile '</krpano>'
    }
    function Add-manufacturerDevelXml {
        Write-Debug "   > devel.xml"
        $develFile = "$dir\$tour\files\devel.xml"
        New-Item -ItemType File $develFile -Force | Out-Null
        Add-Content $develFile '<?xml version="1.0" encoding="UTF-8"?>'
        Add-Content $develFile ('<krpano version="' + $krVersion + '">')
        Add-Content $develFile '    <krpano logkey="true" />'
        Add-Content $develFile '    <develmode enabled="true" />'
        Add-Content $develFile '    <!-- Content -->'
        $contentfolder = Get-ChildItem "$dir\$tour\files\content\*.xml"  |
        foreach { Add-Content $develFile ('    <include url="%CURRENTXML%/content/' + $_.BaseName + '.xml" />') }
        Add-Content $develFile '    <!-- Include -->'
        $includefolder = Get-ChildItem "$dir\shared\include\"  |
        foreach { Add-Content $develFile ('    <include url="%SWFPATH%/include/' + $_.BaseName + '/index.xml" />') }
        Add-Content $develFile '    <!-- Scenes -->'
        $scenesfolder = Get-ChildItem "$dir\$tour\files\scenes\*.xml"  |
        foreach { Add-Content $develFile ('    <include url="%CURRENTXML%/scenes/' + $_.BaseName + '.xml" />') }
        Add-Content $develFile '</krpano>'
    }
    # This function is used by Add-GforcesTourXml and Add-GforcesBrandXml
    function Add-ToManufacturerTourXml ($selectedFolder) {
        foreach ($xmlFile in $selectedFolder) {
            Get-Content $xmlFile |
            # Skip the lines containing krpano tags
            where { $_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_.trim() -ne "" } |
            # Remove any whitespace before ="
            foreach { $_ -replace '\s+="','="' } |
            # Add custom images to cars from 'nl'
            foreach {
                if ($countrycode -eq "nl") {
                    $_ -replace 'tions/inst', 'tions/nl_inst' `
                       -replace 'fs.png', 'nl_fs.png' `
                       -replace 'message.png', 'nl_message.png' `
                } else { $_ }
            } |
            # Remove any whitespace at the start of each line. Do this always the last thing in this function
            foreach { $_.ToString().TrimStart() |
            Add-Content $tourFile
            }
        }
    }
    function Add-ManufacturerTourXml {
        Write-Debug "   > tour.xml"
        $tourFile = "$dir\$tour\files\tour.xml"
        New-Item -ItemType File $tourFile -Force | Out-Null
        Add-Content $tourFile '<?xml version="1.0" encoding="UTF-8"?>'
        Add-Content $tourFile ('<krpano version="' + $krVersion + '">')
        Add-Content $tourFile '<krpano logkey="true" />'
        # Add XML files inside 'content' folder
        $contentFolder = Get-ChildItem "$dir\$tour\files\content\*.xml"
        Add-ToManufacturerTourXml $contentFolder
        # Add XML files inside 'include' folder
        $includeFolder = Get-ChildItem "$dir\shared\include\*\*.xml" -Exclude coordfinder, editor_and_options
        Add-ToManufacturerTourXml $includeFolder
        # Add XML files inside 'scenes' folder
        $scenesFolder = Get-ChildItem "$dir\$tour\files\scenes\*.xml"
        Add-ToManufacturerTourXml $scenesFolder
        Add-Content $tourFile '</krpano>'
    }
}
Process {
    # Check that the objects taken from the pipeline exist in config.xml
    foreach ( $brand in $configXml.tour.brand ) {
        foreach ($car in $brand.car) {
            $tour = $($car.id) | where { $_ -match $TourName.BaseName }
            if ($tour -notlike "" ){
                Write-Verbose ">> $tour"
                # Extract information from the car file name
                # Add index.html and devel.html
                Add-ManufacturerHtmlFiles
                # Add 'car/files/content/coord.xml' and 'car/files/content/panolist.xml'
                Add-ManufacturerContent
                # Add 'car/files/devel.xml'
                Add-ManufacturerDevelXml
                # Add 'car/file/tour.xml'
                Add-ManufacturerTourXml
            }
        }
    }
}
End {
    Write-Verbose "-------------------- Index --------------------"
    # Check that all the car folders contain any HTML file.
    # If there isn't one, that would mean that I generated the tiles for a car, but I didn't add the details to config.xml
    # and run the script to generate the tour files
    Get-ChildItem . -Exclude .custom, .src, .no_scenes, brands, shared -Directory |
        foreach {
            if(!(Test-Path "$($_.FullName)/*.html")){Throw "The follwing folder doesn't contain any HTLM files: $($_.FullName)`
            This is probably because I generated the tiles but I didn't add the details to the config.xml file"}
        }
    $tour = $configXml.tour.brand
    # index.html
    Get-Content "$dir\.src\html\index_template.html" |
    foreach {
        if ($_ -match 'ADDCONTENT' ) {
            foreach ($brand in $tour) {
                '            <h4>' + $brand.id + '</h4>'
                '            <ul>'
                foreach ($car in $brand.car) {
                    '                <li><a href="SERVERNAME/' + $car.id + '/index.html" title="' + $car.name + '">'+ $car.id + '</a></li>'
                }
                '            <ul>'
            }
        }
        else
        {
            $_
        }
    } |
    foreach {($_).replace('NEWPATH','.')} |
    foreach {($_).replace('HOMEPATH','.')} |
    foreach {($_).replace('./brands/index.html','./index.html')} |
    foreach {($_).replace('.brands {','.brands {display:none;')} |
    foreach {($_).replace('SERVERNAME',$configXML.tour.url) } |
    Set-Content "$dir\index.html"
    Write-Verbose ">> index.html"
    # devel.html
    Get-Content "$dir\.src\html\index_template.html" |
    foreach {
        if ($_ -match 'ADDCONTENT' ) {
            foreach ($brand in $tour) {
                '            <h4>' + $brand.id + '</h4>'
                '            <ul>'
                foreach ($car in $brand.car) {
                    '                <li><a href="./' + $car.id + '/devel.html" title="' + $car.name + '">'+ $car.id + '</a></li>'
                }
                '            <ul>'
            }
        }
        else
        {
            $_
        }
    } |
    foreach {($_).replace('NEWPATH','.')} |
    foreach {($_).replace('HOMEPATH','.')} |
    foreach {($_).replace('./brands/index.html','./index.html')} |
    foreach {($_).replace('.brands {','.brands {display:none;')} |
    foreach {($_).replace('</style>','.home-content{background:palegoldenrod;}</style>')} |
    Set-Content "$dir\devel.html"
    Write-Verbose ">> devel.html"
    # Rename cars
    $renameTour = $configXml.tour.rename.car
        foreach ($renameCar in $renameTour) {
        [Array]$renameThisCars += $renameCar
    }
    if ($renameThisCars -notlike "") {
        Write-Verbose "-------------------- Rename Cars --------------------"
    }
    foreach ($renameCar in $renameThisCars) {
            $carID = $($renameCar.id)
            $carRenameTo = $($renameCar.renameTo)
            #Write-Host $carID
            #Write-Host $carRenameTo
            # Delete folder with the wrong name
            if ( Test-Path $dir\$carRenameTo ) {
                Remove-Item $dir\$carRenameTo -Recurse -Force
            }
            # Create a new folder with the wrong name with a folder named 'files' inside it
            New-Item -Path $dir\$carRenameTo -ItemType Directory | Out-Null
            New-Item -Path $dir\$carRenameTo\files -ItemType Directory | Out-Null
            # Copy original 'index.html' file replacing wrong name for the right one
            $index_content = Get-Content $dir\$carID\index.html
            $index_content |
            foreach { ($_).replace($CarID,$carRenameTo ) } |
            Out-File -Encoding utf8 $dir\$carRenameTo\index.html
            # Copy original 'tour.xml' file replacing wrong name for the right one
            $index_content = Get-Content $dir\$carID\files\tour.xml
            $index_content |
            foreach { ($_).replace($CarID + '"',$carRenameTo + '"' ) } |
            Out-File -Encoding utf8 $dir\$carRenameTo\files\tour.xml
            Write-Verbose ">> $carID > $carRenameTo"
    }
}
