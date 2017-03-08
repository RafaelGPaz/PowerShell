<#
.Synopsis
   Backup System
.DESCRIPTION
    There are three options:
    1- IMG: Image backup of HOME directory and E:/ drive (WORK)
    2- PLUS: Incremental backup of HOME directory and E:/ drive (WORK)
    3- All: IMG and PLUS backups
    4- OLD: work_old_1 to work_old_2
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

function Img-Backup {
    param()
    write-verbose "HOME IMG Backup in process ..." -Verbose
    $batfile = [diagnostics.process]::Start("$conf_dir\home_img.ffs_batch")
    $batfile.WaitForExit()
    write-verbose "WORK IMG backup in process ..." -Verbose
    $batfile = [diagnostics.process]::Start("$conf_dir\work_img.ffs_batch")
    $batfile.WaitForExit()
}

function Plus-Backup {
    param()
    write-verbose "HOME PLUS Backup in process ..." -Verbose
    $batfile = [diagnostics.process]::Start("$conf_dir\home_plus.ffs_batch")
    $batfile.WaitForExit()
    write-verbose "WORK PLUS Backup in process ..." -Verbose
    $batfile = [diagnostics.process]::Start("$conf_dir\work_plus.ffs_batch")
    $batfile.WaitForExit()
}
function Old-Backup {
    param()
    write-verbose "WORK OLD Backup in process ..." -Verbose
    $batfile = [diagnostics.process]::Start("$conf_dir\work_old.ffs_batch")
    $batfile.WaitForExit()
}

function Backup-All {
    Img-Backup
    Plus-Backup
}

Clear-Host
$conf_dir = "E:\documents\freefilesync"

# Choose what to backup
$title = "Backup"
$message = "What would you lite to backup?"

$one = New-Object System.Management.Automation.Host.ChoiceDescription "&Img", `
    "IMG"

$two = New-Object System.Management.Automation.Host.ChoiceDescription "&Plus", `
    "PLUS"

$three = New-Object System.Management.Automation.Host.ChoiceDescription "&All", `
    "All"

$four = New-Object System.Management.Automation.Host.ChoiceDescription "&Old", `
    "Old"

$options = [System.Management.Automation.Host.ChoiceDescription[]]($one, $two, $three, $four)

$result = $host.ui.PromptForChoice($title, $message, $options, 1)

Switch( $result ){
    0{ Img-Backup }
    1{ Plus-Backup }
    2{ Backup-All }
    3{ Old-Backup }
}

Write-Verbose "EOF" -Verbose