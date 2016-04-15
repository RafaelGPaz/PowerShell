<#
.Synopsis
   Create virtual tour tiles using Krpano-tools
.DESCRIPTION
    There are three options:
    1- 2 Levels: tilesize=902, 2 levels
    2- 3 Levels: tilesize=902, 3 levels
    2- Site Survey: tilesize=756, 2 levels
.EXAMPLE
   Run from the same directory containing the folder '.src'
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
    $ErrorActionPreference = "Stop"
    $origin = "E:\virtual_tours\clarendon_apartments"
    $destination = "E:\virtual_tours\clarendon_apartments_tourvista"
    [xml]$apartments= Get-Content "E:\virtual_tours\clarendon_apartments_tourvista\.src\config.xml"
    }

Process {
    $apartments.tour.zone | where { $_.id -match $TourName.BaseName } | foreach {
        $zone_name = $_.id
        $zone_path = "$destination\$zone_name"
        if(!(Test-Path -Path "$zone_path" )) { 
            New-Item -Path "$zone_path" -ItemType Directory | Out-Null           
        }
        #write-verbose "$zone_name"
        $_.apartment | foreach {
            $apartment_name = $_.id
            $apartment_path = "$destination\$zone_name\$apartment_name"
            if(!(Test-Path -Path "$apartment_path" )) { 
                New-Item -Path "$apartment_path" -ItemType Directory | Out-Null
            }
            #write-verbose "----$apartment_name"
            $_.bed | foreach {
                $bed_name = $_.id
                $bed_origin = $_.origin
                $bed_path = "$destination\$zone_name\$apartment_name\$bed_name"
                $tour_origin = "$origin\$bed_origin\files\tour.xml"
                $tour_destination = "$destination\$zone_name\$apartment_name\$bed_name\files\tour.xml"
                #%SWFPATH%/../../1bed/files/scenes/scene1/preview.jpg
                #%SWFPATH%/../dde_64/files/scenes/scene1/preview.jpg
                $old_path = "%SWFPATH%/../../$bed_origin"
                $new_path = "%SWFPATH%/../../$bed_name"
                #Copy-Item -Recurse -Force "$origin\$bed_origin\devel\" "$destination\$zone_name\$apartment_name\$bed_name\" -Verbose
                #Copy-Item -Recurse -Force "$origin\$bed_origin\*.html" "$destination\$zone_name\$apartment_name\$bed_name\" -Verbose
                #Copy-Item -Recurse -Force "$origin\$bed_origin\files\content\" "$destination\$zone_name\$apartment_name\$bed_name\files\" -Verbose
                #Copy-Item -Recurse -Force "$origin\$bed_origin\files\include\" "$destination\$zone_name\$apartment_name\$bed_name\files\" -Verbose
                #Copy-Item -Recurse -Force "$origin\$bed_origin\files\plugins\" "$destination\$zone_name\$apartment_name\$bed_name\files\" -Verbose
                #Copy-Item -Recurse -Force "$origin\$bed_origin\files\*.js" "$destination\$zone_name\$apartment_name\$bed_name\files\" -Verbose
                #Copy-Item -Recurse -Force "$origin\$bed_origin\files\*.swf" "$destination\$zone_name\$apartment_name\$bed_name\files\" -Verbose
                #Copy-Item -Recurse -Force "$origin\$bed_origin\files\devel.xml" "$destination\$zone_name\$apartment_name\$bed_name\files" -Verbose
                if(!(Test-Path -Path "$destination\$zone_name\$apartment_name\$bed_name\files")) { 
                    New-Item -Path "$destination\$zone_name\$apartment_name\$bed_name\files" -ItemType Directory | Out-Null
                }
                if(!(Test-Path -Path "$bed_path" )) { 
                    New-Item -Path "$bed_path" -ItemType Directory | Out-Null
                }
                if(Test-Path -Path $tour_destination) { 
                    Remove-Item -Path $tour_destination -force
                }
                $a = "set(layer[view_btn_1].onclick,loadpano('../../%1/files/tour.xml',null,IGNOREKEEP|REMOVESCENES,BLEND(1)));"
                $b = "set(layer[view_btn_1].onclick,openurl(../%1/index.html,_self));"
                $c = "set(layer[view_btn_2].onclick,loadpano('../../%2/files/tour.xml',null,IGNOREKEEP|REMOVESCENES,BLEND(1)));"
                $d = "set(layer[view_btn_2].onclick,openurl(../%2/index.html,_self));"
                $e = "set(layer[view_btn_3].onclick,loadpano('../../%3/files/tour.xml',null,IGNOREKEEP|REMOVESCENES,BLEND(1)));"
                $f = "set(layer[view_btn_3].onclick,openurl(../%3/index.html,_self));"
                $g = "set(layer[view_btn_4].onclick,loadpano('../../%4/files/tour.xml',null,IGNOREKEEP|REMOVESCENES,BLEND(1)));"
                $h = "set(layer[view_btn_4].onclick,openurl(../%4/index.html,_self));"
                Get-content $tour_origin |
                foreach {($_).replace('<layer name="logoclient"','<layer name="logoclient" visible="false"' ) } |
                foreach {($_).replace('x="210"','x="110"' ) } |
                foreach {($_).replace('<addlogoclient enabled="true" />','<addlogoclient enabled="false" />' ) } |
                foreach {($_).replace($a,$b ) } |
                foreach {($_).replace($c,$d ) } |
                foreach {($_).replace($e,$f ) } | 
                foreach {($_).replace($g,$h ) } | 
                foreach {($_).replace( $old_path , $new_path )} |
                foreach {($_).replace( 'berwick_street_2_bed))' , '2bed))' )} |
                foreach {($_).replace( 'berwick_street_1_bed))' , '1bed))' )} |
                foreach {($_).replace( 'brushfield_street_51a))' , '1bed))' )} |
                foreach {($_).replace( 'brushfield_street_45))' , '2bed))' )} |
                foreach {($_).replace( 'chandos_place_3))' , '2bed))' )} |
                foreach {($_).replace( 'chandos_place_2))' , '1bed))' )} |
                foreach {($_).replace( 'clarendon_house_5))' , '3bed))' )} |
                foreach {($_).replace( 'clarendon_house_1))' , '2bed))' )} |
                foreach {($_).replace( '(clarendon_house_2' , '(1bed' )} |
                foreach {($_).replace( '(clarendon_house_1' , '(2bed' )} |
                foreach {($_).replace( 'dde_64))' , '1bed))' )} |
                foreach {($_).replace( 'dde_41))' , '2bed))' )} |
                foreach {($_).replace( 'manning_place_11))' , '1bed))' )} |
                foreach {($_).replace( 'manning_place_10))' , '2bed))' )} |
                foreach {($_).replace( 'minories_14))' , '2bed))' )} |
                foreach {($_).replace( 'minories_4))' , '1bed))' )} |
                foreach {($_).replace( 'wraysbury_hall_10))' , '3bed))' )} |
                foreach {($_).replace( 'wraysbury_hall_9))' , '2bed))' )} |
                foreach {($_).replace( '(wraysbury_hall_1' , '(1bed' )} |
                foreach {($_).replace( '(wraysbury_hall_9' , '(2bed' )} |
                foreach {($_).replace( 'west_street_2_bed))' , '2bed))' )} |
                foreach {($_).replace( 'west_street_1_bed))' , '1bed))' )} |
                foreach {($_).replace( 'garrick_street_25_2_bed))' , '2bed))' )} |
                foreach {($_).replace( 'garrick_street_25_1_bed))' , '1bed))' )} |
                foreach {($_).replace( '(garrick_street_25_1_bed' , '(1bed' )} |
                foreach {($_).replace( '(garrick_street_25_openplan' , '(openplan' )} |
                foreach {($_).replace( '(marylebone_4' , '(1bed' )} |
                foreach {($_).replace( '(marylebone_9' , '(studio' )} |
                foreach {($_).replace( 'marylebone_14))' , '2bed_3))' )} |
                foreach {($_).replace( 'marylebone_7))' , '2bed_2))' )} |
                foreach {($_).replace( 'marylebone_2, marylebone_7,' , '2bed_1, 2bed_2,' )} |
                foreach {($_).replace( 'marylebone_4, marylebone_7,' , '1bed, 2bed_2,' )} |
                foreach {($_).replace( 'marylebone_4, marylebone_2,' , '1bed, 2bed_1,' )} |
                Add-Content $tour_destination
                write-verbose "$zone_name | $apartment_name | $bed_name" 
            }
        }
    }
}

End {
    Write-Verbose "_EOF_"
}