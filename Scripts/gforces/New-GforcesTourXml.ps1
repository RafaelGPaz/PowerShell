<#
.DESCRIPTION
    Create a new tour.xml file merging all the XML files in the following directories: 
    - files/content
    - ../../shared/include
    - files/include (if exists)
    - files/scenes
.EXAMPLE
    New-GforcesTourXml  .\lexus_rc_topaz-brown_2015\
    New-GforcesTourXml  .\lexus_rc_topaz-brown_2015\ -Verbose
    Get-ChildItem .\*lexus | New-GforcesTourXml
#>
[CmdletBinding()]             
    Param (                        
        [Parameter(
            Mandatory=$False, 
            ValueFromPipeline=$true)]
        $Param1,
        [String] $IncludeFolder
        )

Begin {
    Clear-Host
    Write-Verbose "Start"

    function Add-IncludeXmlFiles ($IncludePath,$basedir) {
    Write-Verbose '[ OK ] Include'
    $IncludePath = $IncludePath.replace('\\', '\')
    Write-Verbose "       ($IncludePath)"
    $include = Get-ChildItem $IncludePath\*\*.xml -Exclude 'coordfinder', 'editor_and_options'
    if($include -eq $null) { rm $tourfile; Throw "There are no xml files in the 'include' directory" }
    #Write-Verbose =  $include.Directory.Name
    ForEach ($file in $include) {
    #if ($IncludePath -eq "$Param1\files\include") {
    #Write-Verbose "   $($file.Directory.Name)/index.xml"
    #} else {
    #    Write-Verbose "   shared/$($file.Directory.Name)/index.xml"
    #}
    Write-Verbose "       $basedir/$IncludeFolder/$($file.Directory.BaseName)"
    #Write-Host $IncludeFolder
    Add-Content $tourfile $(Get-Content $file.FullName | 
    where {$_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_ -notmatch '<?xml version' -and $_.trim() -ne "" } |
    foreach {$_.ToString().TrimStart() }  
    Out-String ) }    
    }
}
Process {
    # Convert Param1 in an object just in case it's given a string
    $Param1 = Get-Item $Param1
    foreach ($TourPath in $Param1) {
        Write-Verbose ">>>>>> $($TourPath.BaseName)"
        if(!(Test-Path -Path "$TourPath\files")) { Throw "There is no 'files' directory. Are you in the right directory?" }
        $tourfile="$TourPath\files\tour.xml"
        if(!(Test-Path -Path $tourfile)) {
        touch $tourfile
        } else {
        rm $tourfile
        }
        # Head
        set-content $tourfile  '<krpano version="1.18" showerrors="false"><krpano logkey="true" />'

        # Plugins Directory
        $plugins = Get-ChildItem $TourPath\..\shared\plugins\*.xml
        Write-Verbose '[ OK ] Plugins'
        ForEach ($file in $plugins) {
            Write-Verbose "       $($file.Name)"
            Add-Content $tourfile $(Get-Content $file.FullName | 
            where {$_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_ -notmatch '<?xml version' -and $_.trim() -ne "" } |
            foreach {$_.ToString().TrimStart() }  
            Out-String)
        }
        # Content Directory
        if(!(Test-Path -Path "$TourPath\files\content")) { rm $tourfile; Throw "There is no 'content' directory" 
        }
        $content = Get-ChildItem $TourPath\files\content\*.xml
        if($content -eq $null) { rm $tourfile; Throw "There are no xml files in the 'content' directory" }
        Write-Verbose '[ OK ] Content'
        ForEach ($file in $content) {
            Write-Verbose "       $($file.Name)"
            Add-Content $tourfile $(Get-Content $file.FullName | 
            where {$_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_ -notmatch '<?xml version' -and $_.trim() -ne "" } |
            foreach {$_.ToString().TrimStart() }  
            Out-String)
        }
        # Incude Directory
        #Add-IncludeXmlFiles -IncludePath "$TourPath\files\include"
        #Add-IncludeXmlFiles -IncludePath "$TourPath\..\shared\$IncludeFolder"
        # Make 'include' the default value of $IncludeFolder
        if($IncludeFolder -eq '') { $IncludeFolder='include' }
        # Add XML files
        if(Test-Path -Path "$TourPath\files\include") {
            Add-IncludeXmlFiles -IncludePath "$TourPath\files\$IncludeFolder"
        } else {
            if(!(Test-Path -Path "$TourPath\..\shared\$IncludeFolder")) { Throw "The directory shared/$IncludeFolder doesn't exist." }
            Add-IncludeXmlFiles -IncludePath "$TourPath\..\shared\$IncludeFolder" -basedir "shared"
        }

        # Scenes Directory
        if(!(Test-Path -Path "$TourPath\files\scenes")) { rm $tourfile; Throw "There is no 'scenes' directory" }
        #$scenes = Get-ChildItem .\files\scenes\*.xml
        $scenes = Get-ChildItem $TourPath\files\scenes\*.xml -Exclude info*.xml
        if($scenes -eq $null) { rm $tourfile; Throw "There are no xml files in the 'scenes' directory" }
        Write-Verbose '[ OK ] Scenes'
        ForEach ($file in $scenes) {
            Write-Verbose "       $($file.Name)"
            # Open scene tag
            #Add-Content  $tourfile "<scene name=`"$($_.BaseName)`">";  
            # scenes\scene#.xml
            Add-Content $tourfile $(Get-Content $file.FullName |
            where {$_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_.trim() -ne "" } |
            #foreach {$_.ToString().TrimStart().Replace("url=`"scene","url=`"`%SWFPATH`%/scenes/scene") } |
            foreach {$_.ToString().TrimStart() } |
            Out-String);
            #Add-Content  $tourfile "</scene>"; 
        }
        # Tail
        Add-Content $tourfile  "</krpano>"
    }
}