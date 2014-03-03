# 
$directory = dir $pwd -Directory -Exclude scorm_files, zip_files_* 
$directory | 
    foreach { 
        Write-Host -ForegroundColor Green "[ - ]" $_.BaseName".zip"
        rm $_".zip"
        Write-Host -ForegroundColor Green "[ + ]" $_.BaseName".zip"
        $files = dir $_.FullName
        write-Zip -path $files -outputpath $_".zip" -Quiet | Out-Null    
    }
Write-Host -ForegroundColor Yellow [ i ] done        