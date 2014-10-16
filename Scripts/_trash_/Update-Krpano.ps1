<#
.Synopsis
   It moves a new version of Krpano in the Downloads folder, to the krpano folder. It also embed the license.
.DESCRIPTION
   Usage:Run the script from anywhere
   Requisites: Download the latest versions zip files to "~/Downloads/"
   krpano viewer: krpano-X.XX.X.zip
   krpano tool: krpanotools-X.XX.X-win64
   New folders: 
     software\virtual_tours\krpano\krpano_viewer\krpano-X.XX.X
     software\virtual_tours\krpano\krpano_tools\krpanotools-X.XX.X
   New files with license embeded: 
     virtual_tours\.archives\bin\newvt\src\structure\files\tour.swf
     virtual_tours\.archives\bin\newvt\src\structure\files\tour.js
     virtual_tours\.archives\bin\newvt\src\structure\files\devel.swf
     virtual_tours\.archives\bin\newvt\src\structure\files\devel.js
   All the plugins in 'virtual_tours\.archives\bin\newvt\src\plugins' will be upgraded
.EXAMPLE
   Update-Krpano.ps1
#>

function unzip($file) {
    if (!(test-path $file)) {throw "Can't find zip file"}
    # destination needs split - [0][1]
    $destination = (Join-Path $PWD ($file).basename)
    if (!(test-path $destination)) {
        mkdir $destination
        $file = ($file).fullname
        $shell = new-object -com shell.application
        $zip = $shell.NameSpace($file)
        foreach($item in $zip.items())
        {
            $shell.Namespace($destination).copyhere($item)
        }
    }
}

Clear-Host

$kr_viewer = Get-Item "C:\Users\rafaelgp\Downloads\krpano-*.zip"
$kr_tools = Get-Item "C:\Users\rafaelgp\Downloads\krpanotools-*.zip"
$kr_viewer_dir = "C:\Users\rafaelgp\work\documents\software\virtual_tours\krpano\krpano_viewer"
$kr_tools_dir = "C:\Users\rafaelgp\work\documents\software\virtual_tours\krpano\krpano_tools"

# Unzip the viewer and the toors
Write-Verbose "Unzip $kr_viewer" -Verbose
unzip -file $kr_viewer
Write-Verbose "Unziping $kr_tools" -Verbose
unzip -file $kr_tools
# Romove zip files
#rm $kr_viewer -Force
#rm $kr_tools -Force

# Move files to 'krpano' directory
Write-Verbose "Moving $($kr_viewer.BaseName)" -Verbose
$kr_tools_folder = $kr_tools.BaseName.split("-")[0] + "-" + $kr_tools.BaseName.split("-")[1]
mv $kr_viewer.BaseName $kr_viewer_dir -Force
Write-Verbose "Moving $($kr_tools_folder)" -Verbose
mv $kr_tools.BaseName $kr_tools_dir\$kr_tools_folder -Force

# Copy all the licenses but the free branding. That will be copied after generate devel.swf/devel.js
Write-Verbose "Coping licenses" -Verbose
$license_dir = "C:\Users\rafaelgp\work\documents\software\virtual_tours\krpano\krpano_license"
cp $license_dir\krpano.license $kr_viewer_dir\$($kr_viewer.BaseName)\
cp $license_dir\krpano.license $kr_tools_dir\$kr_tools_folder\
cp $license_dir\krpanotools.license $kr_tools_dir\$kr_tools_folder\
cp $license_dir\krpanoiphone.license.js $kr_tools_dir\$kr_tools_folder\

# Krpano settings
$krversion = $kr_tools.BaseName.split("-")[1]
$krdir = "c:\Users\rafaelgp\work\documents\software\virtual_tours\krpano"
$krpath = "$krdir\krpano_tools\krpanotools-$krversion\kmakemultires.exe"
$krconfig = "-config=$krdir\krpano_tools\krpanotools-$krversion\templates\vtour-normal.config"
$panopath = "$license_dir\pano.jpg"
$newvt = "C:\Users\rafaelgp\work\virtual_tours\.archives\bin\newvt\src\structure\files"
$plugins_dir = "C:\Users\rafaelgp\work\virtual_tours\.archives\bin\newvt\src\plugins"

# Generate the files containing the license
Write-Verbose "Generating devel.swf / devel.js" -Verbose
Invoke-Expression "$krpath $krconfig $panopath" | Out-Null
cp $license_dir\vtour\tour.swf $newvt\devel.swf -Force
cp $license_dir\vtour\tour.js $newvt\devel.js -Force
rm $license_dir\vtour  -Recurse -Force

# Generate files with the branding free licenese
Write-Verbose "Generating tour.swf / tour.js" -Verbose
cp $license_dir\krpanobrandingfree.license $kr_tools_dir\$($kr_tools_folder)\
Invoke-Expression "$krpath $krconfig $panopath" | Out-Null
cp $license_dir\vtour\tour.swf $newvt\tour.swf -Force
cp $license_dir\vtour\tour.js $newvt\tour.js -Force
rm $license_dir\vtour  -Recurse -Force

# Copy all plugins 
Write-Verbose "Coping plugins" -Verbose
dir $plugins_dir |
    foreach {
    cp $kr_viewer_dir\$($kr_viewer.BaseName)\plugins\$($_.Name) $plugins_dir -Force
    }

Write-Verbose "Done" -Verbose