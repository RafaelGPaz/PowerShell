<#
.DESCRIPTION
    Create tour.xml file for each tour folder in the current directory

    tour.xml merge all the XML files contained in:
    1- './tour/files/content/*.xml'
    2- './shared/include/*/index.xml' directory if exists
    3- './tour/files/include/*/index.xml'
    4- './tour/files/scenes/*.xml'

    Run the script from the same directory than the folder '.src'

#>
[CmdletBinding()]
Param (
[Parameter(
    Mandatory=$False,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$true)]
    $TourName
    )
Begin {
    #$DebugPreference = "Continue"
    # Stop if there is any error
    $ErrorActionPreference = "Stop"
    $krVersion = "1.18"
    $dir = $pwd
    $excludeDirs = ".*", "brands", "shared", "local_usage_flash", "localusage", "local_usage"
    $dirs = Get-ChildItem -Path $pwd -Exclude $excludeDirs -Directory
    if(!(Test-Path -Path "$dir\.src")) { Throw "There is no '.src' directory. Are you in the right directory?" }
    Write-Verbose "Checking files and folders...."
    foreach ( $tour in $dirs ) {
        if(!(Get-ChildItem "$dir\.src\panos\$($tour.BaseName)\*.jpg" )) { Throw "There are no JPG panoramos in the directory '.src/panos'" }
        [Array]$toursArray += $tour
        foreach ( $scene in $(Get-ChildItem "$dir\.src\panos\$($tour.BaseName)\*.jpg")) {
            if(!(Test-Path "$dir\$($tour.BaseName)\files" )) { Throw "Folder '$dir\$($tour.BaseName)\files' NOT FOUND. Did you create the tiles correctly?" }
            if(!(Test-Path "$dir\$($tour.BaseName)\files\scenes" )) { Throw "Folder '$dir\$($tour.BaseName)\files\scenes' NOT FOUND. Did you create the tiles correctly?" }
            if(!(Test-Path "$dir\$($tour.BaseName)\files\scenes\$($scene.BaseName)" )) { Throw "Folder '$dir\$($tour.BaseName)\files\scenes\$($scene.BaseName)' NOT FOUND. Did you create the tiles correctly?" }
            if(!(Test-Path "$dir\$($tour.BaseName)\files\scenes\$($scene.BaseName).xml" )) { Throw "File .\$($tour.BaseName)\files\scenes\$($scene.BaseName).xml NOT FOUND. Did you create the tiles correctly?" }
        }
    }
     # Check there aren't folders or files which don't belong to an existing panorama
    foreach ( $tour in $(Get-ChildItem "$dir" -Exclude $excludeDirs -Directory) ) {
        foreach ( $scene in $(Get-ChildItem "$dir\$($tour.BaseName)\files\scenes\" -Directory )) {
            if(!(Test-Path ".src\panos\$($tour.BaseName)\$($scene.BaseName).jpg" )) {
                throw "The following folder is obsolete: '.\$($tour.BaseName)\files\scenes\$($scene.BaseName)'"
            }
        }
        foreach ( $scene in $(Get-ChildItem "$dir\$($tour.BaseName)\files\scenes\*.xml" )) {
            if(!(Test-Path ".src\panos\$($tour.BaseName)\$($scene.BaseName).jpg" )) {
                throw "The following file is obsolete: '.\$($tour.BaseName)\files\scenes\$($scene.BaseName).xml'"
            }
        }
    }

    function Clean-TourXml ($selectedFolder) {
        foreach ($xmlFile in $selectedFolder) {
            Get-Content $xmlFile |
            # Skip the lines containing krpano tags
            where { $_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_.trim() -ne "" } |
            # Remove any whitespace before ="
            foreach { $_ -replace '\s+="','="' } |
            # Remove any whitespace at the start of each line. Do this always the last thing in this function
            foreach { $_.ToString().TrimStart() |
            Add-Content $tourFile
            }
        }
    }
}

Process {
    if (!($tourName)) {
        $tourName = $toursArray
    }
    Write-Verbose "$($tourName.BaseName)"
    foreach ($tour in $tourName) {
        $tourFile = "$dir\$($tour.BaseName)\files\tour.xml"
        New-Item -ItemType File $tourFile -Force | Out-Null
        #<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<krpano version=\"$krpano_version\" onstart=\"startup();\" showerrors=\"false\">
        $head = '<?xml version="1.0" encoding="UTF-8"?><krpano version="' + $krVersion + '" logkey="false" showerrors="false" onstart="startup();" >'
        Add-Content $tourFile $head
        # PLUGINS
        if(Test-Path "$dir\shared") {
            if (Get-ChildItem "$dir\shared\plugins\*.xml") {
                Write-Verbose "    PLUGINS:"
                foreach ($xmlFile in $(Get-ChildItem "$dir\shared\plugins\*.xml" )) {
                    Write-Verbose "    [ OK ] $($xmlFile.Directory.Basename)/$($xmlFile.BaseName).xml"
                    $pluginsFolder = $xmlFile
                    Clean-TourXml $pluginsFolder
                }
            }
        }
        else
        {
            if (Get-ChildItem "$dir\$($tour.BaseName)\files\plugins\*.xml") {
                Write-Verbose "    PLUGINS:"
                foreach ($xmlFile in $(Get-ChildItem "$dir\$($tour.BaseName)\files\plugins\*.xml" )) {
                    Write-Verbose "    [ OK ] $($xmlFile.Directory.Basename)/$($xmlFile.BaseName).xml"
                    $pluginsFolder = $xmlFile
                    Clean-TourXml $pluginsFolder
                }
            }
        }
        # CONTENT
        Write-Verbose "    CONTENT:"
        foreach ($xmlFile in $(Get-ChildItem "$dir\$($tour.BaseName)\files\content\*.xml")) {
            Write-Verbose "    [ OK ] $($xmlFile.Directory.Basename)/$($xmlFile.BaseName).xml"
            Clean-TourXml $xmlFile
        }
        # INCLUDE
        if(Test-Path "$dir\shared") {
            if (Get-ChildItem "$dir\shared\include\*\*.xml") {
                Write-Verbose "    INCLUDE:"
                foreach ($xmlFile in $(Get-ChildItem "$dir\shared\include\*\*.xml" -Exclude coordfinder, editor_and_options)) {
                    Write-Verbose "    [ OK ] $($xmlFile.Directory.Basename)/$($xmlFile.BaseName).xml"
                    $includeFolder = $xmlFile
                    Clean-TourXml $includeFolder
                }
            }
        }
        else
        {
            if (Get-ChildItem "$dir\$($tour.BaseName)\files\include\*\*.xml") {
                Write-Verbose "    INCLUDE:"
                foreach ($xmlFile in $(Get-ChildItem "$dir\$($tour.BaseName)\files\include\*\*.xml" -Exclude coordfinder, editor_and_options)) {
                    Write-Verbose "    [ OK ] $($xmlFile.Directory.Basename)/$($xmlFile.BaseName).xml"
                    $includeFolder = $xmlFile
                    Clean-TourXml $includeFolder
                }
            }
        }
        # SCENES
        if (Get-ChildItem "$dir\$($tour.BaseName)\files\scenes\*.xml") {
            Write-Verbose "    SCENES:"
            foreach ($xmlFile in $(Get-ChildItem "$dir\$($tour.BaseName)\files\scenes\*.xml")) {
                Write-Verbose "    [ OK ] $($xmlFile.Directory.Basename)/$($xmlFile.BaseName).xml"
                $scenesFolder = $xmlFile
                Clean-TourXml $scenesFolder
            }
        }
        Add-Content $tourFile '</krpano>'
    }
}

End {
    Write-Verbose "_EOF_"
}

