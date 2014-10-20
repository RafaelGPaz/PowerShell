<#
.DESCRIPTION
 Creates thumbnails to use by the scroll feature (420 x 210)
 IMPORTANT: Go to the directory where all the jpg files are before running the script
 The output folder is scroll_panos
#>

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