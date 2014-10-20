# Make-Thumbs.ps1
# It creates 'thumbs' directory if it doesn't exists
# It creates a thumbnail for every jpg file in the current directory, if it doesn't exist inside 'thumbs' directory.

Clear-Host

$check_dir = Test-Path -PathType Container thumbs
if($check_dir -eq $false){
    New-Item thumbs -type directory | Out-Null
}

$all_img = dir ".\*.jpg"
Write-Host [ info ] Number of images: $all_img.count -ForegroundColor Blue
foreach ( $img_in in dir $all_img ) { 
    $img_out = $($img_in).name
    $check_thumb = Test-path -PathType Leaf thumbs\$img_out
    if($check_thumb -eq $false) {   
        write-host "[ info ] Creating thumb: $img_out ..." -ForegroundColor Blue
        Invoke-Expression "C:\'Program Files (x86)'\ImageMagick-6.8.9-Q16\convert.exe $img_in -resize 420x210^ -gravity center -extent 200x120 thumbs\$img_out"
        write-host "[  ok ] $img_out" -ForegroundColor Green
    }
    else {
        write-host "[  ok  ] $img_out" -ForegroundColor Green
    }
}
write-host [ ---- ] End -ForegroundColor Green 