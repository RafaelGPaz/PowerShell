function Add-Folder ($newdir) {
    if (!(Test-Path $newdir)) {
        New-Item -ItemType Directory $newdir | Out-Null
    }
}

function Confirm-ConfigFile {
    <#
    .DESCRIPTION
        It creates config.xml file if it's not present
    #>
    [CmdletBinding()]
    Param ()             

    $configFile = '.\config.xml'
    $project = $(Get-Item .).BaseName
    #Remove-Item $configFile -Force
    if (Test-Path $configFile) {
        Write-Verbose "File config.xml OK" 
    }
    else
    {
        Write-Warning "File config.xml not found. Creating one"
        New-Item -ItemType File $configFile -Force | Out-Null
        Add-Content $configFile -Encoding UTF8 (
@"
<?xml version="1.0" encoding="UTF-8"?>
<tour>
"@)
    Add-Content $configFile -Encoding UTF8 ('    <path url="http://www.clients.tourvista.co.uk/vt/' + $project + '/files" crossdomain="http://www.clients.tourvista.co.uk/crossdomain.xml"></path>')
    Add-Content $configFile -Encoding UTF8 (
@"         
<!-- <path url="./files" crossdomain="./crossdomain.xml"></path> -->

    <plugin coordfinder="y"
            editor_and_options="y"
            global="y"
            gyro="y"
            movecamera="y"
            sa="y"
            startup="y"
                    
"@)
    $allPlugins = Get-ChildItem -Path "E:\virtual_tours\.archives\bin\newvt\src\include" -Directory -Exclude "coordfinder","editor_and_options","global","gyro","movecamera","sa","startup"
    $allPlugins | foreach { Add-Content $configFile -Encoding UTF8 ('            ' + $_.BaseName + '="n"') }
    Add-Content $configFile -Encoding UTF8 (
@"
    />
    <options logo_client_name="1"
             scroll_more="title"
             list="y" 
    />

</tour>
"@)
    }
}

function Add-SrcDirectory {
<#
.DESCRIPTION
    It creates all the necessary folders for the .custom directory
#>
    [CmdletBinding()]
    Param() 

    Add-Folder ".\.src"
    Add-Folder ".\.src\panos"
    Add-Folder ".\.src\html"
}

function Add-TourXml {
<#
.DESCRIPTION
    It creates the file tour.xml which contains information about the tour
#>
    [CmdletBinding()]
    Param( 
        [string[]] 
        $ToursArray
    )
    # ---------- TOURS ARRAY ----------
    # Stop if there isn't any tour folders inside the panos directory?
    if(!(Get-ChildItem -Directory ".\.src\panos")) { Throw "Folder .src\panos is EMPTY. Create a folder with the project's name and put the panoramas inside." }
    $ToursArray = Get-ChildItem -Directory '.\.src\panos' | Foreach-Object {$_.Name}
    # ---------- SCENES ARRAY ----------
    $ToursArray | ForEach-Object {
        if(Test-Path variable:$_.BaseName){ Remove-Variable -Name $_.BaseName }
        $SceneName=Get-ChildItem ".\.src\panos\$_\*.jpg"
        # Stop if there aren't any images in the tour folder
        if(!($SceneName)) { Throw "Folder .src\panos\$_ doesn't contain any JPG images" }
        New-Variable -Name $_ -Value ($SceneName | Select -ExpandProperty BaseName)
    }
    # Now let's create the file
    $tourFile='.\tour.xml'
    if (!(Test-Path $tourFile)) {
        Write-Warning "File tour.xml not found. Creating one."
        New-Item -ItemType File .\tour.xml -Force | Out-Null
        Add-Content $tourFile ('<?xml version="1.0" encoding="UTF-8"?>')
        Add-Content $tourFile ('<vt>')
        $ToursArray | ForEach-Object {
            Add-Content $tourFile ('    <tour id="' + $_ + '">')
                $(Get-Variable $_).Value | foreach {
                    Add-Content $tourFile ('        <scene id="' + $_ + '" name="" h="0" v="0" />')
                }
            Add-Content $tourFile ('    </tour>')
        }
        Add-Content $tourFile ('</vt>')
    }
}

function Add-CustomDirectory {
<#
.DESCRIPTION
    It creates all the necessary folders for the .custom directory
#>
    [CmdletBinding()]
    Param( 
        $tour
    )     
    Add-Folder ".\.custom"
    Add-Folder ".\.custom\html"
    
    # Add .custom/include if there are more than 1 scene
    if($tour.Count -gt 1 ) {
        Add-Folder ".\.custom\include"
    }
}

function Add-FolderStructure {
<#
.DESCRIPTION
    It creates all the necessary files and folders for the project
#>
    [CmdletBinding()]
    Param( 
        $tour
    )
    # Print Tours information
    Write-Verbose "$($tour.id)"
    Write-Verbose "  Scenes: $($tour.scene.count)"
    # Add folders
    Add-Folder .\$($tour.id)
    Add-Folder .\$($tour.id)\files
    Add-Folder .\$($tour.id)\files\content
    Add-Folder .\$($tour.id)\files\include
    Add-Folder .\$($tour.id)\files\plugins
    # Add files
    $src_dir="E:\virtual_tours\.archives\bin\newvt\src"
    Copy-Item $src_dir\structure\files\tour.js .\$($tour.id)\files\ -Force
    Copy-Item $src_dir\structure\files\tour.swf .\$($tour.id)\files\ -Force
}

function Remove-OldFiles {
<#
.DESCRIPTION
    It removes all the html files inside the tour folder
#>
    [CmdletBinding()]
    Param( 
        $tour
    )
    Write-Verbose "  [ OK ] Clean HTML files"
    Get-ChildItem ".\$($tour.id)\*.html" | foreach { Remove-Item $_.FullName | Out-Null }
}

function Add-Includes {
    <#
    .DESCRIPTION
        Add, Delete, or Keep the plugis folder to the directory 'files/include' 
    #>
    [CmdletBinding()]             
    Param (
        $tour
        ,
        $configXml
    )
    Write-Verbose "  [ OK ] Adding Includes"
    Get-ChildItem -Directory "E:\virtual_tours\.archives\bin\newvt\src\include\" | foreach {
            $pluginName = $configXml.tour.plugin.GetAttribute($_.name)
            # If value is "y", copy the plugin folder
            if ($pluginName -eq "y") {
                $pluginValue = $($_.name)
                Copy-Item -Recurse -Force "E:\virtual_tours\.archives\bin\newvt\src\include\$pluginValue" ".\$($tour.id)\files\include\" 
            }
            # If value is "n", delete the plugin folder
            if ($pluginName -eq "n") {
                $pluginValue = $($_.name) 
                if(Test-Path ".\$($tour.id)\files\include\$pluginValue") {
                    Remove-Item -Recurse -Force ".\$($tour.id)\files\include\$pluginValue"
                }
            }
            # if value is "k", don't do anything
    }
    # Copy any folders in the directory .custom\include
    Get-ChildItem -Directory ".\.custom\include" | ForEach-Object {
        Copy-Item -Recurse -Force "$($_.FullName)" ".\$($tour.id)\files\include\"
    }
}

function Add-IncludePanolist {
    <#
    .DESCRIPTION
        Add file 'content/panolist.xml'
        This file is used by Krpano to get each scene name
    #>
    [CmdletBinding()]             
    Param (
        $tour , $krVersion
    )
    Write-Verbose "  [ OK ] Adding panolist.xml"
    $saXml = ".\$($tour.id)\files\content\panolist.xml"
    Set-Content $saXml -Encoding UTF8 ('<krpano version ="' + $krVersion + '">')
    Add-Content $saXml -Encoding UTF8 ('    <layer name="panolist" keep="true">')
    $counter = 1
    $($tour.scene) | foreach {
        Add-Content $saXml -Encoding UTF8 ('    <pano name="' + $($_.id) + '"')
        Add-Content $saXml -Encoding UTF8 ('          scene="' + $($_.id) + '"')
        Add-Content $saXml -Encoding UTF8 ('          pageurl="/scene' + $counter + '/"')
        Add-Content $saXml -Encoding UTF8 ('          pagetitle="' + $($_.name) + '"')
        Add-Content $saXml -Encoding UTF8 ('          title="' + $($_.name) + '"')
        Add-Content $saXml -Encoding UTF8 ('          custom=""')
        Add-Content $saXml -Encoding UTF8 ('    />')
        $counter = $counter + 1
        }
    Add-Content $saXml -Encoding UTF8 ('    </layer>')
    Add-Content $saXml -Encoding UTF8 ('</krpano>')
}

function Add-IncludeMovecamera {
    <#
    .DESCRIPTION
        Add file 'content/coord.xml'
        This file is used set the point of interest at the start of atour
    #>
    [CmdletBinding()]             
    Param (
        $tour , $krVersion
    )
    Write-Verbose "  [ OK ] Adding coord.xml"
    $coordXml = ".\$($tour.id)\files\content\coord.xml"
    Set-Content $coordXml -Encoding UTF8 ('<krpano version ="' + $krVersion + '">')
    $counter = 1
    $($tour.scene) | foreach {
        Add-Content $coordXml -Encoding UTF8 ('    <action name="movecamera_' + $($_.id) + '">movecamera(' + $($_.h) + ',' + $($_.v) + ');</action>')
        $counter = $counter + 1
    }
    Add-Content $coordXml -Encoding UTF8 ('</krpano>')
}

function Add-IncludeLogoClient {
    <#
    .DESCRIPTION
        Add a client's logo. 
        There are 3 options for the parameter "logo_client_name" (located in config.xml file):
            1 = Creare
            2 = Addoctor
            3 = Llama Digital
    #>
    [CmdletBinding()]             
    Param (
        $tour, $configXml
    )
    if ($configXml.tour.plugin.GetAttribute("logo_client") -eq "y") {
        $clientVar = $configXml.tour.options.GetAttribute("logo_client_name")
        $fileName = ".\$($tour.id)\files\include\logo_client"
        if ($clientVar -eq "1") { $clientName = "creare" }
        if ($clientVar -eq "2") { $clientName = "addoctor" }
        if ($clientVar -eq "3") { $clientName = "llama" }
        Get-Content $fileName\index.xml | 
            foreach { ($_).replace('CLIENTNAME',"$($clientName)") } |
            Set-Content $fileName\index.temp
        Move-Item -Force $fileName\index.temp $fileName\index.xml
        Write-Verbose "  [ OK ] Adding logo for $clientName"
    }
}

function Add-IncludeHotspots {
    <#
    .DESCRIPTION
        Add hotspots feature
        If several tours need hotspots, but there are some with only 1 scene, the script doesn't add the folder to them.
    #>
    [CmdletBinding()]             
    Param (
        $tour, $configXml
    )
    if ($configXml.tour.plugin.GetAttribute("hotspots") -eq "y") {
        Write-Verbose "  [ OK ] Adding hs.xml"
        if ($tour.scene.count -gt 1) {
            $fileName = ".\$($tour.id)\files\include\hotspots\index.xml"
            Set-Content $fileName -Encoding UTF8 ('<krpano version ="' + $krVersion + '">')
            $counter = 1
            $($tour.scene) | foreach {
                Set-Content $fileName -Encoding UTF8 ('    <action name="add_hs_scene' + $counter + '">')
                Set-Content $fileName -Encoding UTF8 ('        hs(up, scene, get(layer[panolist].pano[scene].title),0,0,0,0);')
                Set-Content $fileName -Encoding UTF8 ('    </action>')
                $counter = $counter + 1
            }
        Add-Content $fileName -Encoding UTF8 ('</krpano>')
        } else {
            # TODO: Delete hs.xml and include/hotspots/
        }
    }
}

function Add-PluginInfoBtn {
    <#
    .DESCRIPTION
        Add the file devel.xml
    #>
    [CmdletBinding()]             
    Param (
        $tour, $configXml
    )
    
}

function Add-DevelXml {
    <#
    .DESCRIPTION
        Add the file devel.xml
    #>
    [CmdletBinding()]             
    Param (
        $tour
        ,
        $krVersion
    )
    Write-Verbose "  [ OK ] Adding devel.xml"
    $develXml = ".\$($tour.id)\files\devel.xml"
    New-Item -ItemType File $develXml -Force | Out-Null
    Add-Content $develXml -Encoding UTF8 '<?xml version="1.0" encoding="UTF-8"?>'
    Add-Content $develXml -Encoding UTF8 "<krpano version=`"$krVersion`">"
    Add-Content $develXml -Encoding UTF8 '    <krpano logkey="true" />'
    Add-Content $develXml -Encoding UTF8 '    <develmode enabled="true" />'
    Get-ChildItem ".\$($tour.id)\files\content\*.xml" | ForEach-Object {
        Add-Content $develXml -Encoding UTF8 "    <include url=`"%SWFPATH%/content/$($_.Name)`" />"
    }
    Get-ChildItem -Directory ".\$($tour.id)\files\include\" | ForEach-Object {
        Add-Content $develXml -Encoding UTF8 "    <include url=`"%SWFPATH%/include/$($_.basename)/index.xml`" />"
    }
    Get-ChildItem ".\$($tour.id)\files\scenes\*.xml" | ForEach-Object {
        Add-Content $develXml -Encoding UTF8 "    <include url=`"%SWFPATH%/scenes/$($_.basename).xml`" />"
    }
    Add-Content $develXml -Encoding UTF8 '</krpano>'
}

function Add-KrpanoPlugins {
    <#
    .DESCRIPTION
    #>
    [CmdletBinding()]             
    Param (
        $tour 
    )
    Write-Verbose "  [ OK ] Adding Krpano plugins"
    $binPlugins = "E:\virtual_tours\.archives\bin\newvt\src\plugins"
    $tourPlugins = ".\$($tour.id)\files\plugins\"
    Copy-Item -Force "$binPlugins\editor.swf" $tourPlugins
    Copy-Item -Force "$binPlugins\options.swf" $tourPlugins
    Copy-Item -Force "$binPlugins\textfield.swf" $tourPlugins
}

function Add-HtmlFiles {
    <#
    .DESCRIPTION
        Add several HTML files
        Devel: No need to create that folder. Just move it from the newvt\src
        Devel Scenes: One per scene, named with just a number
        Scenes: One per scene
        Custom: Add any HTML files inside the .custom/html directory
        Index: the file index.html is a copy of scene1.html
    #>
    [CmdletBinding()]             
    Param (
        $tour 
        , 
        $configXml
    )
    # Move devel folder
    Copy-Item -Recurse -Force "E:\virtual_tours\.archives\bin\newvt\src\html\devel\" ".\$($tour.id)\"
    Write-Verbose "  [ OK ] Adding HTML files"
    $counter = 1
    $($tour.scene) | ForEach {
        $sceneName = $_.id
        # Devel Scenes
        Get-Content "E:\virtual_tours\.archives\bin\newvt\src\html\devel.html" | 
            foreach { ($_).replace('SCENENAME',$sceneName) } |
            Out-File -Encoding utf8 ".\$($tour.id)\devel\$counter.html"
        $counter = $counter + 1
        # Scenes
        $tourPath = $configXml.tour.path.url
        Get-Content "E:\virtual_tours\.archives\bin\newvt\src\html\scene.html" | 
            foreach { ($_).replace('SCENENAME',$sceneName) } |
            foreach { ($_).replace('files',$tourPath) } |
            Out-File -Encoding utf8 ".\$($tour.id)\$sceneName.html"
    }
    # Custom directory
    Get-ChildItem ".\.custom\html\*.html" | foreach {
        Copy-Item -Force "$($_.FullName)" ".\$($tour.id)\"
     }
    # index.html
    if(Test-Path ".\$($_.id)\scene1.html") {
        Copy-Item -Force ".\$($_.id)\scene1.html" ".\$($_.id)\index.html"
    }
}

function Add-HtmlList {
    <#
    .DESCRIPTION
        It creates 2 index files:
        - index.html 
            It contains a list of all virtual tours and scenes, with links to open each tour list.html
        - list.html
            This is a list of scenes for each tour  
        
        It copies the template to the directory .src\ just in case I need to do some changes to it.
        By defaul it tries to use the 'name' parameter to display the names.
        If that field is empty, then it falls back to the parameter 'id'
        The file index.html in each tour directory is a copy of the file scene1.html
    #>
    [CmdletBinding()]             
    Param (
        $tour
    )
    Write-Verbose "[ OK ] Adding index.html"
    # CSS
    if(!(Test-Path ".\.src\html\style.css")) {
        Copy-Item "E:\virtual_tours\.archives\bin\newvt\src\generate_html\style.css" ".\.src\html\"
    }
    Copy-Item ".\.src\html\style.css" ".\"
    # HTML
    if(!(Test-Path ".\.src\html\index-template.html")) {
        Copy-Item "E:\virtual_tours\.archives\bin\newvt\src\generate_html\template.html" ".\.src\html\index-template.html"
    }
    # index.html
    Get-Content ".\.src\html\index-template.html" | 
    foreach $_ {
        if ($_ -cmatch 'CONTENT' ) {
            $tour | foreach {
                $tourId = $_.id
                if ($_.name -eq "") { $tourName = $_.id } else { $tourName = $_.name }
                $scene = $_.scene
                    '            <h4><a href="./' + $tourId + '/list.html">' + $tourName + '</a></h4>'
                    '            <ul>'
                    $scene | foreach {
                        $sceneId = $_.id
                        if ($_.name -eq "") { $sceneName = $_.id } else { $sceneName = $_.name }
                        '                <li><a href="./' + $tourId + '/' + $sceneId + '.html">'+ $sceneName + '</a></li>'
                    }
                    '            </ul>'
                }
        } else {
            $_
        }
    } | 
    Set-Content ".\index.html"

    # list.html
    foreach ($tourItem in $tour) {
        Get-Content ".\.src\html\index-template.html" | 
            foreach $_ {
                if ($_ -cmatch 'CONTENT' ) {
                    $tourId = $tourItem.id
                    if ($tourItem.name -eq "") { $tourName = $tourItem.id } else { $tourName = $tourItem.name }
                    $scene = $tourItem.scene
                        '            <h4>' + $tourName + '</h4>'
                        '            <ul>'
                        $scene | foreach {
                            $sceneId = $_.id
                            if ($_.name -eq "") { $sceneName = $_.id } else { $sceneName = $_.name }
                            '                <li><a href="./' + $sceneId + '.html">'+ $sceneName + '</a></li>'
                        }
                        '            </ul>'
                } else {
                    $_
                }
            } | 
        foreach $_ {($_).replace('./style.css','../style.css')} |
        foreach $_ {($_).replace('<h1>Virtual Tours List</h1>','<h1><a href="../index.html">Virtual Tours List</a></h1>')} |
        Set-Content ".\$($tourItem.id)\list.html"
    } 
}

function Merge-XmlFiles {
    <#
    .DESCRIPTION
        Merge files
    #>
    [CmdletBinding()]             
        Param (                        
            [Parameter(Mandatory=$False, 
                Position=0)]  
            [String]$Param1
            )#End Param
    if(!(Test-Path -Path ".\files")) { Throw "There is no 'files' directory. Are you in the right directory?" }
    $tourfile=".\files\tour.xml"
    if(!(Test-Path -Path $tourfile)) { Throw "There is no 'tour.xml' file" }
    rm $tourfile
    New-Item -ItemType File -path $tourfile | Out-Null
    # Head
    set-content $tourfile  '<krpano version="1.17" showerrors="false"><krpano logkey="true" />'

    # Content Directory
    if(!(Test-Path -Path ".\files\content")) { rm $tourfile; Throw "There is no 'content' directory" 
    }
    $content = Get-ChildItem .\files\content\*.xml
    if($content -eq $null) { rm $tourfile; Throw "There are no xml files in the 'content' directory" }
    Write-Output '===== Content ====='
    Write-Output $content.Name 
    ForEach ($file in $content) {Add-Content $tourfile $(Get-Content $file.FullName | 
    where {$_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_ -notmatch '<?xml version' -and $_.trim() -ne "" } |
    foreach {$_.ToString().TrimStart() }  
    Out-String) }

    # Incude Directory
    if(!(Test-Path -Path ".\files\include")) { rm $tourfile; Throw "There is no 'include' directory" }
    $include = Get-ChildItem .\files\include\*\*.xml -Exclude 'coordfinder', 'editor_and_options'
    if($include -eq $null) { rm $tourfile; Throw "There are no xml files in the 'include' directory" }
    Write-Output '===== Include ====='
    #Write-Output =  $include.Directory.Name
    ForEach ($file in $include) {
    Write-Output "$($file.Directory.Name)/index.xml"
    Add-Content $tourfile $(Get-Content $file.FullName | 
    where {$_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_ -notmatch '<?xml version' -and $_.trim() -ne "" } |
    foreach {$_.ToString().TrimStart() }  
    Out-String ) }

    # Scenes Directory
    if(!(Test-Path -Path ".\files\scenes")) { rm $tourfile; Throw "There is no 'scenes' directory" }
    #$scenes = Get-ChildItem .\files\scenes\*.xml
    $scenes = Get-ChildItem .\files\scenes\*.xml -Exclude info*.xml
    if($scenes -eq $null) { rm $tourfile; Throw "There are no xml files in the 'scenes' directory" }
    Write-Output '===== Scenes ====='
    Write-Output $scenes.Name
    ForEach ($file in $scenes) {
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
    Write-Output "_EOF_"
}