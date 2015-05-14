<#
.Synopsis
   Backup System
.DESCRIPTION
    There are three options:
    1- Home: Backup only the Home directory
    2- Work: Backup only the E:/ drive
    3- All: Backup both Home and Work
    4- VirtualBox - Backup VirtualBox directory
.EXAMPLE
   Run-Backup
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

function Backup-Home {
    param()
    write-verbose "Backing up Home img ..." -Verbose
    $batfile = [diagnostics.process]::Start("$conf_dir\home_img.ffs_batch")
    $batfile.WaitForExit()
    write-verbose "Backing up Home plus ..." -Verbose
    $batfile = [diagnostics.process]::Start("$conf_dir\home_plus.ffs_batch")
    $batfile.WaitForExit()
}

function Backup-Work {
    param()
    write-verbose "Backing up Work img ..." -Verbose
    $batfile = [diagnostics.process]::Start("$conf_dir\work_img.ffs_batch")
    $batfile.WaitForExit()
    write-verbose "Backing up Work plus ..." -Verbose
    $batfile = [diagnostics.process]::Start("$conf_dir\work_plus.ffs_batch")
    $batfile.WaitForExit()
}

function Backup-All {
    Backup-Home
    Backup-Work
}

function Backup-VirtualBox {
    param()
    write-verbose "Backing up VirtualBox ..." -Verbose
    $batfile = [diagnostics.process]::Start("$conf_dir\virtualbox.ffs_batch")
    $batfile.WaitForExit()
}

Clear-Host
$conf_dir = "E:\documents\freefilesync"

# Choose what to backup   
$title = "Backup"
$message = "What would you lite to backup?"

$one = New-Object System.Management.Automation.Host.ChoiceDescription "&Home", `
    "Home"

$two = New-Object System.Management.Automation.Host.ChoiceDescription "&Work", `
    "Work"

$three = New-Object System.Management.Automation.Host.ChoiceDescription "&All", `
    "All"

$four = New-Object System.Management.Automation.Host.ChoiceDescription "&VirtualBox", `
    "VirtualBox"

$options = [System.Management.Automation.Host.ChoiceDescription[]]($one, $two, $three, $four)

$result = $host.ui.PromptForChoice($title, $message, $options, 2) 

Switch( $result ){
    0{ Backup-Home }
    1{ Backup-Work }
    2{ Backup-All }
    3{ Backup-VirtualBox }
}

Write-Verbose "EOF" -Verbose