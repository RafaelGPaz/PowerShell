# Download latest Concrete5 version to Downloads directory
# Then unzip and delete the zip file

function start-download {
    clear-Host
    $url = "http://www.concrete5.org/developers/downloads/"
    $geturl=Invoke-WebRequest $url
    $searchlink = ($geturl.Links) | Where href -match 'download_file'
    $searchlink = ($searchlink)[0].href
    $source = "http://www.concrete5.org" + $searchlink
    write-host "Downloading: $source"
    $destination = "C:\Users\rafaelgp\Downloads\concrete5.zip"
    $client = New-Object System.Net.Webclient
    $client.Credentials = New-Object System.Net.NetworkCredential("123456","78910")
    $client.DownloadFile($source, $destination)
}

function unzip {
    Set-Location -Path "C:\Users\rafaelgp\Downloads"
    $shell_app=new-object -com shell.application
    $filename = "concrete5.zip"
    write-host "Unzip $filename"
    $zip_file = $shell_app.namespace((Get-Location).Path + "\$filename")
    $destination = $shell_app.namespace((Get-Location).Path)
    $destination.Copyhere($zip_file.items())
    Remove-Item $filename
}

start-download
unzip
write-host "Done!"