<#
.Synopsis
   Command line tool to quickly create avirtual tour using a custom config file
.DESCRIPTION
   Navigate to the folder containing the pano image
   Run command.
   Select the config file
.EXAMPLE
   Example of how to use this cmdlet
#>
function Verb-Noun
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Param1,

        # Param2 help description
        [int]
        $Param2
    )

    Begin
    {
    }
    Process
    {
    .\krpanotools64.exe makepano -config="..\krpano_conf\templates\tv_8192px_cube.config" ..\output\pano1.jpg
    }
    End
    {
    }
}