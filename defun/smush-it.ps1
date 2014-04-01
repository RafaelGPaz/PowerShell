<#
.Synopsis
   Java program to optimise image files using http://smush.it
.DESCRIPTION
   Java program to optimise image files using http://smush.it
.EXAMPLE
   smush-it images/
#>

[cmdletbinding()]

    Param
    (
        [Parameter(Mandatory=$true)]
        $imageDir
    )

$VerbosePreference = "Continue"

function smush-it {
    java -jar "E:\virtual_tours\.archives\bin\smushit\smushit.jar" "-imageDir=$imageDir"
}

Clear-Host
smush-it -imageDir $imageDir