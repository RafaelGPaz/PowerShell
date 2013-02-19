Push-Location $psScriptRoot
. $posh_dir\vendor\posh-git\Utils.ps1
. $posh_dir\vendor\posh-git\GitUtils.ps1
. $posh_dir\vendor\posh-git\GitPrompt.ps1
. $posh_dir\vendor\posh-git\GitTabExpansion.ps1
. $posh_dir\vendor\posh-git\TortoiseGit.ps1
Pop-Location

Export-ModuleMember -Function @(
        'Write-GitStatus', 
        'Get-GitStatus', 
        'Enable-GitColors', 
        'Get-GitDirectory',
        'GitTabExpansion',
        'tgit')