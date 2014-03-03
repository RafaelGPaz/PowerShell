# There's usually much more than this in my profile!
$vimpath = "C:\Program Files (x86)\Vim\vim73\vim.exe"

Set-Alias vi   $vimpath
Set-Alias vim  $vimpath

# for editing your PowerShell profile
Function Edit-Profile
{
    vim $profile
}

# for editing your Vim settings
Function Edit-Vimrc
{
    vim "$home\AppData\Roaming\.vimrc"
}

# Function to enable pipe into Vim
# Example: gci *.ps1 | vf
Function vf ()
{
    $filepaths = $input | Get-Item | % { $_.fullname }
    vim $filepaths
}