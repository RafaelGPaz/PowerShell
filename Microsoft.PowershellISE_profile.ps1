
function Prompt
{
    $promptString = "PS " + $(Get-Location) + ">"
    Write-Host $promptString -NoNewline -ForegroundColor Yellow
    return " "
}

# Load posh-git example profile
. 'C:\Users\rafaelgp\Documents\WindowsPowerShell\conf\posh-git\profile.example.ps1'
