#function Reload-Profile {
    @(
        $Profile.AllUsersAllHosts,
        $Profile.AllUsersCurrentHost,
        $Profile.CurrentUserAllHosts,
        $Profile.CurrentUserCurrentHost
    ) | ForEach-Object {
        if(Test-Path $_){
            Write-Verbose "Loading $_" -Verbose
            . $_
        }
    }
#}