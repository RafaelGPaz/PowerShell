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
Param ()
$tourXml = '.\tour.xml'
if (!(Test-Path "$tourXml")) {
    Write-Warning "File tour.xml not found. Created one automatically"
    Add-Content $tourXml '<?xml version="1.0" encoding="UTF-8"?>'
    Add-Content $tourXml '<vt>'
    Get-ChildItem '.\.src\panos' -Directory |
        foreach {
            Add-Content $tourXml "    <tour id=`"$($_.BaseName)`" name=`"`">"
            Get-ChildItem "$($_.FullName)" -Filter "*.jpg" |
            foreach {
                Add-Content $tourXml "        <scene id=`"$($_.BaseName)`" name=`"`" h=`"0`" v=`"0`" />"
            }
            Add-Content $tourXml "    </tour>"
        }
    Add-Content $tourXml '</vt>'
}
[xml]$sourceTour = Get-Content $tourXml
$tour = $sourceTour.vt.tour
Write-Verbose "[ OK ] Adding index.html"
if (!(Test-Path ".\.src\html")) {mkdir ".\.src\html"}
# CSS
if(!(Test-Path ".\.src\html\style.css")) {
    Copy-Item "E:\virtual_tours\.archives\bin\newvt\src\generate_html\style.css" ".\.src\html\"
}
# HTML
if(!(Test-Path ".\.src\html\index-template.html")) {
    Copy-Item "E:\virtual_tours\.archives\bin\newvt\src\generate_html\template.html" ".\.src\html\index-template.html"
}
# index.html
Get-Content ".\.src\html\index-template.html" |
foreach $_ {
    if ($_ -cmatch 'CONTENT' ) {
        '            <ul>'
        $tour | foreach {
            $tourId = $_.id
            if ($_.name -eq "") { $tourName = $_.id } else { $tourName = $_.name }
            $scene = $_.scene
                '                <li><a href="./' + $tourId + '/list.html">' + $tourName + '</a></li>'
            }
        '        </ul>'
    } else {
        $_
    }
} |
Set-Content ".\index.html"

# list.html
foreach ($tourItem in $tour) {
    Write-Verbose "[ OK ] Adding list.html for $($tourItem.id)"
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
    foreach $_ {($_).replace('<div class="logo"></div>','<a href="../index.html"><div class="logo"></div></a>')} |
    foreach $_ {($_).replace('"./images','"../images')} |
    Where-Object {$_ -notmatch '<h1>'} |
    Set-Content ".\$($tourItem.id)\list.html"
}