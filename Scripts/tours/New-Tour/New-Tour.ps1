<#
.SYNOPSIS
    Generate Virtual Tour
.DESCRIPTION
    Generate all the required files for a Virtual Tour
.EXAMPLE
    C:\PS>Get-Item [folder_name] | New-Tour -Verbose
#>
    [CmdletBinding()]
    Param (
    [Parameter(
        Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$true)]
        $TourName
        )
    Begin {
        . C:\Users\Rafael\Documents\WindowsPowerShell\Scripts\tours\New-Tour\New-Tour-Functions.ps1
        # Stop if there is any error
        $ErrorActionPreference = "Stop"
        $krVersion = "1.18"
        $configFile =  "config.xml"
        if (Test-Path ".\$configFile") { 
            $configPath = (Get-Item ".\config.xml").FullName

        } else {
            Add-ConfigFile
        }
        break
        Read-ConfigFile
        # If it's a "multiple tours" project create 'shared' folder and copy 'plugins' folder, tour.swf and tour.js inside it
        Add-SharedFolder
        # According to the config file, add and remove folders inside the 'include' directory
        Update-IncludeFolder
    }
    Process {
        # Add one folder for every tour
        Add-TourFolder
        # Add a index.html file which contains a list of all the scenes
        Add-IndexFile
        # Add a HTML FILE fore every scene
        Add-ScenesFiles
        # Add 'devel' folder and one HTML file for each scene
        Add-DevelFolder
        # Add 'content' folder
        Add-ContentFolder
        # If it's a "single tour" project, copy 'plugins' folder, tour.swf and tour.js
        Add-KrpanoFiles
        # If it's a "single tour" project, according to the config file, add and remove folders inside the 'include' directory
        Update-IncludeFolder
        # Add devel.xml
        Add-DevelFile
        # Add tour.xml
        Add-TourFile
    }
    End {
    Write-Verbose "EOF"
    }
