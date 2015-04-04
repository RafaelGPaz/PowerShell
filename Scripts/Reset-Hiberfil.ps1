<#
.Synopsis
   Delete file c:\hiberfil.sys
.DESCRIPTION
   This script sets powercfg to off and then it restarts computer.
   After that the computer
#>

if ($(dir "C:\" -Force -Filter "hiberfil.sys") -eq $null) 
{
    Write-Verbose 'Set PowerCfg: ON' -Verbose
    powercfg.exe /H on
}
else
{
    Write-Verbose 'Set PowerCfg: OFF' -Verbose
    powercfg.exe /H off
    Write-Warning "Restart computer!" -Verbose
    Restart-Computer -Confirm
}