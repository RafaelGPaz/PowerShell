$SourceDir = "."
$DestinationDir = ""

$files = get-childitem $SourceDir *.jpg
foreach ($file in $files) 
{
$Directory = $DestinationDir + "" + $file.LastWriteTime.ToString('yyyy-MM-dd')
#$Directory
if (!(Test-Path $Directory))
	{
	New-Item $directory -type directory
	}
	Move-Item $file.fullname $Directory
}

$folder = Get-ChildItem
foreach ($files in $folder)
{
$prefix = "img_"
$files = Get-ChildItem $files\*.jpg
$id = 1
$files
$files | foreach { Rename-Item -Path $_.fullname -NewName ( $prefix + ((($id++).tostring()).padleft(($files.count.tostring()).length) -replace ' ','0' ) + $_.extension) }
}
#$photos = Get-ChildItem -Recurse .\*JGP
#$($photos.LastWriteTime).ToString("yyyy-mm-d")

# For each photo
# Get year
# Create that folder if it doesn't exists
# Get date
# Create that folder if it doesn't exists
# Copy that photo into that folder

#Same for videos