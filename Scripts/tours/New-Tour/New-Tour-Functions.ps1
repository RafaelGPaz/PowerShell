function Add-Folder ($newdir) {
    if (!(Test-Path $newdir)) { New-Item -ItemType Directory $newdir | Out-Null }
}

function Add-ConfigFile {
    New-Item -ItemType File -Path ".\$configFile" | Out-Null
    $configPath = (Get-Item ".\$configFile").FullName
    Add-Content $configFile '<?xml version="1.0" encoding="UTF-8"?>'
    Add-Content $configFile '<tour>'
    Add-Content $configFile '    <url></url>'
    Add-Content $configFile '    <crossdomain></crossdomain>'
    Add-Content $configFile '</tour>'
}