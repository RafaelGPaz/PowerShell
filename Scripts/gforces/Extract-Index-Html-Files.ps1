<#
.DESCRIPTION
    This script is obsolete. It was used with the folder 'gforces/allcars/'
    Now the Gforces cars are in the directory 'gforces/cars' and there is no need to extrat
    all the HTML files. The script 'New-GforcesTour' already creates and extrat all the
    HTML files inside the folder 'brands'
    Read below a description of what this script USED to do when it was in use:

    It duplicates the folder '.html_files_only' and remove any file that is not named 'index.html'
#>

[CmdletBinding()]
Param
(
    $Param
)

function Start-Script {
    measure-command {
    Write-Verbose "Starting..."
    $allHtml = '.\.html_files_only\'
    $allHtmlCopy  = '.\.index_html_files_only\'
    # Delete the destination folder to start fresh
    Write-Verbose "Delete folder content"
    if (Test-Path $allHtmlCopy) { Remove-Item .\.index_html_files_only\* -Recurse -Force }
    # Duplicate folder
    Write-Verbose "Copy content"
    Copy-Item -Recurse -Force .\.html_files_only\* $allHtmlCopy
    $counter = 1
    # First level
    Write-Verbose "Editing First Level"
    Get-ChildItem "$allHtmlCopy" -File -Filter *.html | 
        foreach {
            Write-Verbose " --> $($_.Name)"
            if ($_.BaseName -ne "index" -and $_.BaseName -ne "brand" -and $_.BaseName -ne "more_brands") {
                Remove-Item $_.FullName
                #Write-Verbose "Delete $($_.Name)"
            }
            if ($_.BaseName -eq "index") {
                Get-Content $_.FullName |
                    foreach { ($_).replace('shared/tourvista','shared/interiors') } |
                    #foreach { ($_).replace('<li><a href="./','<li><a href="https://s3-eu-west-1.amazonaws.com/autofs/shared/tourvista/')} |
                    Set-Content -Force -Encoding UTF8 "$($_.Directory)\$($_.Basename).temp"
                    Move-Item -Force "$($_.Directory)\$($_.BaseName).temp" "$($_.Directory)\$($_.Name)"
                    #Write-Verbose "Edited $($_.Directory)\$($_.Name)"
                    $counter = $counter + 1
            }
        }
    # Second level
    Write-Verbose "Editing Second Level"
    Get-ChildItem $allHtmlCopy -Directory |
        foreach {
            Write-Verbose "--> --> $($_.BaseName)"
            Get-ChildItem $_.FullName -File -Filter *.html | 
            foreach {
                if ($_.BaseName -ne "index" -and $_.BaseName -ne "brand" -and $_.BaseName -ne "more_brands") {
                    Remove-Item $_.FullName
                    #Write-Verbose "Delete $($_.Name)"
                }
                if ($_.BaseName -eq "index") {
                    Get-Content $_.FullName |
                        foreach { ($_).replace('shared/tourvista','shared/interiors') } |
                        Set-Content -Force -Encoding UTF8 "$($_.Directory)\$($_.Basename).temp"
                        Move-Item -Force "$($_.Directory)\$($_.BaseName).temp" "$($_.Directory)\$($_.Name)"
                        #Write-Verbose "Edited $($_.Directory)\$($_.Name)"
                        $counter = $counter + 1
                }
            }
        } 
    # Third level
    Write-Verbose "Editing Third Level"
    Get-ChildItem $allHtmlCopy -Directory |
        foreach { 
            $dir = $_.BaseName
            Get-ChildItem $_.FullName -Directory |
            foreach {
            Write-Verbose "--> --> --> $($_.BaseName)"
            Get-ChildItem $_.FullName -File -Filter *.html | 
                foreach {
                    #if ($_.BaseName -ne "index" -and $_.BaseName -ne "brand" -and $_.BaseName -ne "more_brands") {
                    #    Remove-Item $_.FullName
                        #Write-Verbose "Delete $($_.Name)"
                    #}
                    if ($_.BaseName -eq "index") {
                        Get-Content $_.FullName |
                            foreach { ($_).replace('shared/tourvista','shared/interiors') } |
                            #foreach { ($_).replace('<li><a href="./',"<li><a href=`"https://s3-eu-west-1.amazonaws.com/autofs/shared/tourvista/$($dir)/")} |
                            Set-Content -Force -Encoding UTF8 "$($_.Directory)\$($_.Basename).temp"
                            Move-Item -Force "$($_.Directory)\$($_.BaseName).temp" "$($_.Directory)\$($_.Name)"
                            #Write-Verbose "Edited $($_.Directory)\$($_.Name)"
                            $counter = $counter + 1
                    }
                }
            }
        }
    # Restore CSS files
    Write-Verbose "Restored CSS files"
    Copy-Item .\favicon.ico $allHtmlCopy
    Copy-Item .\html5shiv.js $allHtmlCopy
    Copy-Item .\ie7.css $allHtmlCopy
    Copy-Item .\ie8.css $allHtmlCopy
    Copy-Item .\logo.gif $allHtmlCopy
    Copy-Item .\style.css $allHtmlCopy
    } | select @{n="Total Time";e={$_.Minutes,"minutes",$_.Seconds,"seconds" -join " "}}
    Write-Verbose "Edited $counter index.html files"
}

Start-Script