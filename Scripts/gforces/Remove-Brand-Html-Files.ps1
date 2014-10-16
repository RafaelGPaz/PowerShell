<#
.Synopsis
   Remove any html file that is not "brand.html" or "more_brands.html"
.DESCRIPTION
    I use this script to update Gfoces virtual tours with only the relevant files for the brands interface
#>

write-host "This script deletes any html file that is not brand or more_brand. Are you sure you want to do that?"
write-host "If so, edit the script and remove the break"
break
$a = dir '.\.brand_files_only' -Recurse -Filter *.html -Exclude "brand.html","more_brands.html" 

rm $a -Verbose