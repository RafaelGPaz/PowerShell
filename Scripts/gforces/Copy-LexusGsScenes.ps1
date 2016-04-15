<#
.DESCRIPTION
  
.EXAMPLE
  
#>

[cmdletbinding()]

    Param (
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$false)]
        [Switch] $IgnoreUndercores
        )

$VerbosePreference = "Continue"
# Stop if there is any error
$ErrorActionPreference = "Stop"
$root = 'E:\virtual_tours\gforces\manufacturers\lexus_manufacturer'
$selectedFolder = Get-Childitem $root\ae_lexus_gs350_2016\ae_lexus_gs350_2016\files\scenes

Write-Verbose "[    ] Lexus GS350 Base"
#Copy-Item -Recurse -Force $root\ae_lexus_gs350_base_2016\ae_lexus_gs350_base_2016\files\scenes\* $root\ae_lexus_gs350_2016\ae_lexus_gs350_2016\files\scenes\base\
Write-Verbose "[ OK ]"
Write-Verbose "[    ] Lexus GS350 FSport"
#Copy-Item -Recurse -Force $root\ae_lexus_gs350_fsport_2016\ae_lexus_gs350_fsport_2016\files\scenes\* $root\ae_lexus_gs350_2016\ae_lexus_gs350_2016\files\scenes\fsport\
Write-Verbose "[ OK ]"
Write-Verbose "[    ] Lexus GS350 Luxury"
#Copy-Item -Recurse -Force $root\ae_lexus_gs350_luxury_2016\ae_lexus_gs350_luxury_2016\files\scenes\* $root\ae_lexus_gs350_2016\ae_lexus_gs350_2016\files\scenes\luxury\
Write-Verbose "[ OK ]"
Write-Warning "Run Update-LexusGsSceneFiles.ps1"
Write-Warning "Run Convert_dubai_xmlfiles_to_dos.sh"
Write-Warning "Run merge-lexusxmlfiles.sh"

Write-Verbose "EOF"