# Functions

function add-folder ($newdir) {
    if (!(Test-Path $newdir)) {
        New-Item -ItemType Directory $newdir | Out-Null
    }
}

function check-pano-exists {
    Write-Verbose 'Check jpg panos' -Verbose
    foreach ($brand in $tour) {
        foreach ($model in $brand.model) {
            foreach ($car in $model.car) {
                $pano_path = "$dir\.src\panos\$($brand.id)\$($car.id).jpg"
                if (!(Test-Path $pano_path)) {
                    Write-Error "$($car.id).jpg doesn't exist "
                    break
                }
            }
            $car_pano = Get-ChildItem "$dir\.src\panos\$($brand.id)\*.jpg"
            foreach ($car in  $car_pano) {
                $tiles_path = "$dir\$($brand.id)\files\scenes\$($car.basename)\"
                if (!(Test-Path $tiles_path)) {
                    write-Error "$($car.basename) tiles folder doesn't exist. Run makeTiles.py "
                    break
                }
                $tiles_xml_path = "$dir\$($brand.id)\files\scenes\$($car.basename).xml"
                if (!(Test-Path $tiles_xml_path)) {
                   Write-Error "$($car.basename).xml file doesn't exist. Run makeTiles.py "
                   break
               }
            }
        }
    }
}

function create-folders () {
    Write-Verbose 'Create folders' -Verbose
    #[xml]$xml = get-content $config
    #$tour = $xml.tour.brand
    foreach ($brand in $tour) {
        add-folder "$dir\$($brand.id)"
        add-folder "$dir\$($brand.id)\devel"
        add-folder "$dir\$($brand.id)\files"
        add-folder "$dir\$($brand.id)\files\content"
        add-folder "$dir\$($brand.id)\files\scenes"
        foreach ($old_folder in $(Get-ChildItem -Path "$dir\$($brand.id)" -Directory -Exclude "devel","files")) {Remove-Item -Recurse -Force $old_folder}
        foreach ($model in $brand.model) {
        add-folder "$dir\$($brand.id)\$($model.id)" 
        }
    }
}

function move-krpano-files {
    Write-Verbose 'Move Krpano files' -Verbose
    #[xml]$xml = get-content $config
    #$tour = $xml.tour.brand
    foreach ($brand in $tour) {
        if ((Test-Path $dir\$($brand.id)\files\include)) { Remove-Item -Path $dir\$($brand.id)\files\include -Recurse -Force }
        if ((Test-Path $dir\$($brand.id)\files\include_brand)) { Remove-Item -Path $dir\$($brand.id)\files\include_brand -Recurse -Force }
        if ((Test-Path $dir\$($brand.id)\files\plugins)) { Remove-Item -Path $dir\$($brand.id)\files\plugins -Recurse -Force }
        Copy-Item -Recurse -Force $dir\..\.src\bin\* $dir\$($brand.id)\files\
    }
}

# I have removed creating 'devel/iphone.html' and 'devel/ipad.html' as they are not longer neccessary
function generate-html-files {
    Write-Verbose 'Generate HTML files' -Verbose
    # Copy css file
    Copy-Item -Force "$dir\..\.src\css\style.css" $dir
    #[xml]$xml = get-content $config
    #$tour = $xml.tour.brand
    foreach ($brand in $tour) {
        #$first_car = $brand.car[0].id
        $brand_name = $brand.id
        Remove-Item $dir\$brand_name\*.html -Force
        #Get-Content $dir\.src\html\ipad.html |
        #foreach { ($_).replace('SCENENAME',($first_car + ',null,more')) } |
        #Out-File -Encoding utf8 $dir\$brand_name\devel\ipad.html
        #Write-Verbose ('  ' + $brand_name + '\devel\ipad.html') -Verbose
        #Get-Content $dir\.src\html\iphone.html |
        #foreach { ($_).replace('SCENENAME',($first_car + ',null,more')) } |
        #Out-File -Encoding utf8 $dir\$brand_name\devel\iphone.html
        #Write-Verbose ('  ' + $brand_name + '\devel\iphone.html') -Verbose
        $carnumber = 1
        foreach ($model in $brand.model) {
            foreach ($car in $model.car) {
                Write-Verbose ('  Normal: ' + $car.name ) -Verbose
                # Create an html file for each car
                $template_content = Get-Content $dir\..\.src\html\scene_template.html
                $template_content |
                foreach { ($_).replace('NEWPATH','../..') } | 
                foreach { ($_).replace('SERVERNAME',$xml.tour.url) } | 
                foreach { ($_).replace('BRANDNAME',$brand_name) } |
                foreach { ($_).replace('SCENENAME',$car.id) } |
                Out-File -Encoding utf8 $dir\$brand_name\$($car.id).html
                Copy-Item $dir\$brand_name\$($car.id).html $dir\$brand_name\$($model.id)\$($car.id).html
                #Write-Verbose ('  ' + $($car.id)+'.html') -Verbose
                # Create html files inside 'devel' directory
                $template_content |
                foreach { ($_).replace('NEWPATH','../..') } | 
                foreach { ($_).replace('SERVERNAME','../..') } | 
                foreach { ($_).replace('BRANDNAME',$brand_name) } |
                foreach { ($_).replace('SCENENAME',$car.id) } |
                foreach { ($_).replace('tour.xml','devel.xml') } |
                Out-File -Encoding utf8 $dir\$brand_name\devel\$carnumber.html
                #Write-Verbose ('  ' + $brand_name + '\devel\' + $carnumber+'.html') -Verbose
                $carnumber = $carnumber + 1
            }
        }
    }
}

function generate-all-cars-index-html {
    Write-Verbose 'Generate index.html' -Verbose
    # Create html file
    [xml]$xml = get-content $config
    $tour = $xml.tour.brand
    Get-Content "$dir\..\.src\html\index_template.html" | 
    foreach $_ {
        if ($_ -match 'ADDCONTENT' ) {
            foreach ($brand in $tour) {
                '            <h4><a href="./' + $($brand.id) + '/index.html">' + $($brand.name) + '</a></h4>'
                '            <ul>'
                foreach ($model in $brand.model) { 
                    foreach ($car in $model.car) { 
                        '                <li><a href="./' + $brand.id + '/' + $model.id + '/' + $car.id + '.html" title="' + $car.name + '">'+ $car.id + '</a></li>'
                    }
                }
                '            </ul>'
            }
        }
        else
        {
            $_
        }
    } | 
    foreach $_ {($_).replace('NEWPATH','.')} |
    foreach $_ {($_).replace('All Brands','Grid View')} |
    Set-Content "$dir\index.html"
}

function generate-carmodel-index-html {
    Write-Verbose 'Generate brand\index.html' -Verbose
    #[xml]$xml = get-content $config
    #$tour = $xml.tour.brand
    foreach ($brand in $tour) {
        Get-Content "$dir\..\.src\html\index_template.html" | 
        foreach $_ {
            if ($_ -match 'ADDCONTENT' ) {
                '            <h5><a href="../index.html">(Up One Level)</a></h5>' 
                '            <h4>' + $($brand.name) + '</h4>'
                '            <ul>'
                foreach ($model in $brand.model) { '                <li><a href="./' + $model.id + '/index.html">'+ $model.id + '</a></li>' }
                '            </ul>'
            }
            else
            {
               $_ 
            } 
        } | 
        foreach $_ {($_).replace('NEWPATH','..')} |
        foreach $_ {($_).replace('All Brands','Dark Interface')} |
        foreach $_ {($_).replace('./brands/index.html','./brand.html')} |
        Set-Content "$dir\$($brand.id)\index.html"
    }
}

function generate-carbrand-index-html {
    Write-Verbose 'Generate brand\model\index.html' -Verbose
    #[xml]$xml = get-content $config
    #$tour = $xml.tour.brand
    foreach ($brand in $tour) {
        foreach ($model in $brand.model) {
            Get-Content "$dir\..\.src\html\index_template.html" | 
            where { $_ -notmatch "All Brands" } | 
            foreach $_ {
                if ($_ -match 'ADDCONTENT' ) {
                    '            <h5><a href="../index.html">(Up One Level)</a></h5>' 
                    '            <h4>' + $($brand.name) + ' ' + $($model.name) + '</h4>'
                    '            <ul>'
                            foreach ($car in $model.car) { '                <li><a href="./' + $car.id + '.html" title="' + $car.name + '">'+ $car.id + '</a></li>' }
                    '            </ul>'
                    }
                else
                {
                   $_ 
                } 
            } | 
            foreach $_ {($_).replace('NEWPATH','../..')} |
            foreach $_ {($_).replace('./brands/index.html','./brand.html')} |
            Set-Content "$dir\$($brand.id)\$($model.id)\index.html"
        }
    }
}

function set-crossdomain ($file) {
        $file_content = Get-Content $global_file 
        $file_content | 
             foreach { ($_).replace('[SETCROSSDOMAIN]',$xml.tour.crossdomain)
        } | Out-File -Encoding utf8 $file
}

function add-crossdomain {
    Write-Verbose ('Add crossdomain: ' + $xml.tour.crossdomain) -Verbose
    foreach ($brand in $tour) {
        $global_file = "$dir\$($brand.id)\files\include\global\index.xml"
        set-crossdomain -file $global_file
        $global_file = "$dir\$($brand.id)\files\include_brand\global\index.xml"
        set-crossdomain -file $global_file
    }
}

function generate-coord-xml {
    Write-Verbose 'Generate brand\files\content\coord.xml' -Verbose
    foreach ($brand in $tour) {
        $coordfile = "$dir\$($brand.id)\files\content\coord.xml"
        if (!(Test-Path $coordfile)) {
            New-Item -ItemType File $coordfile | Out-Null
        }
        Set-Content -Force $coordfile '<krpano>'
        foreach ($model in $brand.model) {
            foreach ($car in $model.car) {
                Add-Content $coordfile ('  <action name="movecamera_' + $car.id + '">movecamera(' +  $car.h +  ',' + $car.v + ');</action>')
            }
         }
        Add-Content $coordfile '</krpano>'        
    }
}

function generate-panolist-xml {
    Write-Verbose 'Generate brand\files\content\panolist.xml' -Verbose
    #[xml]$xml = get-content $config
    #$tour = $xml.tour.brand
    foreach ($brand in $tour) {
        $panolistfile = "$dir\$($brand.id)\files\content\panolist.xml"
        New-Item -ItemType File $panolistfile -Force | Out-Null
        Add-Content $panolistfile ('<krpano>')
        Add-Content $panolistfile '    <layer name="panolist" keep="true">'
        foreach ($model in $brand.model) {
            foreach ($car in $model.car) {
                Add-Content $panolistfile ('    <pano name="' + $car.id + '"')
                Add-Content $panolistfile ('          scene="' + $car.name + '"')
                Add-Content $panolistfile ('          title="' + $car.name + '"')
                Add-Content $panolistfile '          />'
            }
        }
        Add-Content $panolistfile '    </layer>'
        Add-Content $panolistfile '</krpano>'
    }
}

function generate-devel-xml {
    Write-Verbose 'Generate brand\files\devel.xml' -Verbose
    #[xml]$xml = get-content $config
    #$tour = $xml.tour.brand
    foreach ($brand in $tour) {
        $develFile = "$dir\$($brand.id)\files\devel.xml"
        New-Item -ItemType File $develFile -Force | Out-Null
        Add-Content $develFile '<?xml version="1.0" encoding="UTF-8"?>'
        Add-Content $develFile ('<krpano version="' + $krver + '">')
        Add-Content $develFile '    <krpano logkey="true" />'
        Add-Content $develFile '    <develmode enabled="true" />'
        Add-Content $develFile '    <!-- Content -->'
        $contentfolder = dir "$dir\$($brand.id)\files\content\*.xml"  |
        foreach $_ { Add-Content $develFile ('    <include url="%SWFPATH%/content/' + $_.BaseName + '.xml" />') }
        Add-Content $develFile '    <!-- Include -->'
        $includefolder = dir "$dir\$($brand.id)\files\include\"  |
        foreach $_ { Add-Content $develFile ('    <include url="%SWFPATH%/include/' + $_.BaseName + '/index.xml" />') }
        Add-Content $develFile '    <!-- Scenes -->'
        $scenesfolder = dir "$dir\$($brand.id)\files\scenes\*.xml"  |
        foreach $_ { Add-Content $develFile ('    <include url="%SWFPATH%/scenes/' + $_.BaseName + '.xml" />') }
        Add-Content $develFile '</krpano>'
    }
}

function add-to-tour-xml ($selectedFolder) {
    foreach ($xmlFile in $selectedFolder) {
        #write-host $xmlFile.fullname
        Get-Content $xmlFile | 
        # Skip the lines containing krpano tags
        where { $_ -notmatch "<krpano" -and $_ -notmatch "</krpano" -and $_.trim() -ne "" } | 
        #foreach { Add-Content $tourFile $_ }
        # Remove any whitespace before ="
        foreach { 
            ($_) -replace('\s+="','="') 
            } |
        # Remove any whitespace at the start of each line
        foreach {
            $_.ToString().TrimStart() | 
            Add-Content $tourFile
        }
    }
}

function generate-tour-xml {
    #[xml]$xml = get-content $config
    #$tour = $xml.tour.brand
    foreach ($brand in $tour) {
        Write-Verbose ('  Generate tour.xml for: ' + $brand.name ) -Verbose
        $tourFile = "$dir\$($brand.id)\files\tour.xml" 
        New-Item -ItemType File $tourFile -Force | Out-Null
        Add-Content $tourFile '<?xml version="1.0" encoding="UTF-8"?>'
        Add-Content $tourFile ('<krpano version="' + $krver + '">')
        Add-Content $tourFile '<krpano logkey="true" />'
        # Add XML files inside 'content' folder
        $contentFolder = Get-ChildItem "$dir\$($brand.id)\files\content\*.xml"
        #Write-Verbose content -Verbose
        add-to-tour-xml $contentFolder
        # Add XML files inside 'include' folder
        $includeFolder = Get-ChildItem "$dir\$($brand.id)\files\include\*\*.xml" -Exclude coordfinder, editor_and_options
        #Write-Verbose include -Verbose
        add-to-tour-xml $includeFolder
        # Add XML files inside 'scenes' folder
        $scenesFolder = Get-ChildItem "$dir\$($brand.id)\files\scenes\*.xml"
        #Write-Verbose scenes -Verbose
        add-to-tour-xml $scenesFolder
        Add-Content $tourFile '</krpano>'
        Copy-Item $dir\$($brand.id)\files\tour.xml $dir\$($brand.id)\files\tour_clean.xml 
    }
}
# TO DO: IT TAKE AGES. TRY TO DON'T USE FOREACH ONLY ONCE
function generate-brands-html {
    Write-Verbose 'Generate brand\brand.html'  -Verbose
    [xml]$xml = get-content $config
    foreach ($brand in $tour) {
        $first_car = $brand.model.car[0].id
        $brand_name = $brand.id
        foreach ($model in $brand.model) {
            foreach ($car in $model.car) {
                Write-Verbose ('  Brand: ' + $car.name ) -Verbose
                # Create brand.html for each brand
                $template_content = Get-Content $dir\..\.src\html\brand_template.html
                $template_content | 
                foreach { ($_).replace('SERVERNAME',$xml.tour.url) } | 
                foreach { ($_).replace('BRANDNAME',$brand_name) } |
                foreach { ($_).replace('SCENENAME',$first_car) } |
                Out-File -Encoding utf8 $dir\$brand_name\brand.html
                # Create more_brands.html for each brand
                $template_content |
                foreach { ($_).replace('SERVERNAME',$xml.tour.url) } | 
                foreach { ($_).replace('BRANDNAME',$brand_name) } |
                foreach { ($_).replace('SCENENAME',($first_car + ',null,more')) } |
                Out-File -Encoding utf8 $dir\$brand_name\more_brands.html
                # Create devel\brand.html 
                $template_content |
                foreach { ($_).replace('SERVERNAME','../..') } | 
                foreach { ($_).replace('BRANDNAME',$brand_name) } |
                foreach { ($_).replace('SCENENAME',$first_car) } |
                foreach { ($_).replace('brand.xml','devel_brand.xml') } |
                Out-File -Encoding utf8 $dir\$brand_name\devel\brand.html
                # Create devel\more_brands.html 
                $template_content |
                foreach { ($_).replace('SERVERNAME','../..') } | 
                foreach { ($_).replace('BRANDNAME',$brand_name) } |
                foreach { ($_).replace('SCENENAME',($first_car + ',null,more')) } |
                foreach { ($_).replace('brand.xml','devel_brand.xml') } |
                Out-File -Encoding utf8 $dir\$brand_name\devel\more_brands.html
            }
        }
    }    
}

function generate-devel-brand-xml {
    Write-Verbose 'Generate brand\files\devel_brand.xml' -Verbose
    #[xml]$xml = get-content $config
    #$tour = $xml.tour.brand
    foreach ($brand in $tour) {
        $develFile = "$dir\$($brand.id)\files\devel_brand.xml"
        New-Item -ItemType File $develFile -Force | Out-Null
        Add-Content $develFile '<?xml version="1.0" encoding="UTF-8"?>'
        Add-Content $develFile ('<krpano version="' + $krver + '">')
        Add-Content $develFile '<krpano logkey="true" />'
        Add-Content $develFile '    <develmode enabled="true" />'
        Add-Content $develFile '    <!-- Content -->'
        $contentfolder = dir "$dir\$($brand.id)\files\content\*.xml"  |
        foreach $_ { Add-Content $develFile ('    <include url="%SWFPATH%/content/' + $_.BaseName + '.xml" />') }
        Add-Content $develFile '    <!-- Include -->'
        $includefolder = dir "$dir\$($brand.id)\files\include_brand\"  |
        foreach $_ { Add-Content $develFile ('    <include url="%SWFPATH%/include_brand/' + $_.BaseName + '/index.xml" />') }
        Add-Content $develFile '    <!-- Scenes -->'
        $scenesfolder = dir "$dir\$($brand.id)\files\scenes\*.xml"  |
        foreach $_ { Add-Content $develFile ('    <include url="%SWFPATH%/scenes/' + $_.BaseName + '.xml" />') }
        Add-Content $develFile '</krpano>'
    }
}

function generate-items-xml {
    Write-Verbose 'Generate brand\files\content\items.xml' -Verbose
    #[xml]$xml = get-content $config
    #$tour = $xml.tour.brand
    foreach ($brand in $tour) {
        $itemsFile = "$dir\$($brand.id)\files\content\items.xml"
        New-Item -ItemType File $itemsFile -Force | Out-Null
        Add-Content $itemsFile ('<krpano>')
        $order = 0
        foreach ($model in $brand.model) {
            foreach ($car in $model.car | where {
            $_.id -notlike 'hyundai_i1' -and 
            $_.id -notlike 'land_rover_range_rover_sport' -and
            $_.id -notlike 'nissan_370z_roadster_open' -and 
            $_.id -notlike 'nissan_leaf' -and 
            $_.id -notlike 'nissan_note' -and 
            $_.id -notlike 'nissan_qashqai' -and 
            $_.id -notlike 'volvo_v70'
            }){
                $y_value = 2 + ($order * 50)
                Add-Content $itemsFile ('<layer name    ="container_1_item_' + $car.id + '"')
                Add-Content $itemsFile ('       html    ="[h1]' + $car.name + '[/h1]"')
                Add-Content $itemsFile ('       onclick ="activatepano(' + ($car.id) + ',scenevariation);"')
                Add-Content $itemsFile ('       style   ="container_1_item_style"')
                Add-Content $itemsFile ('       y       ="' + $y_value + '"')
                Add-Content $itemsFile '        />'
                $order = $order + 1
            }
        }
        Add-Content $itemsFile ('</krpano>')
        $scroll_height = $order * 50
        # Update scroll height after removing some scenes
        $startup_content = Get-Content "$dir\$($brand.id)\files\include_brand\startup\index.xml"
        $startup_content | 
        foreach { ($_).replace('SCROLLHEIGHT',$scroll_height) } |
        Out-File -Encoding utf8 "$dir\$($brand.id)\files\include_brand\startup\index.xml"
    }
}

function generate-brand-xml {
    #[xml]$xml = get-content $config
    #$tour = $xml.tour.brand
    foreach ($brand in $tour) {        
        Write-Verbose ('  Generate brand.xml for: ' + $brand.name ) -Verbose
        $tourFile = "$dir\$($brand.id)\files\brand.xml" 
        New-Item -ItemType File $tourFile -Force | Out-Null
        Add-Content $tourFile '<?xml version="1.0" encoding="UTF-8"?>'
        Add-Content $tourFile ('<krpano version="' + $krver + '">')
        Add-Content $tourFile '<krpano logkey="true" />'
        # Add XML files inside 'content' folder
        $contentFolder = Get-ChildItem "$dir\$($brand.id)\files\content\*.xml"
        add-to-tour-xml $contentFolder
        # Add XML files inside 'include' folder
        $includeFolder = Get-ChildItem "$dir\$($brand.id)\files\include_brand\*\*.xml" -Exclude coordfinder, editor_and_options
        add-to-tour-xml $includeFolder
        # Add XML files inside 'scenes' folder
        $scenesFolder = Get-ChildItem "$dir\$($brand.id)\files\scenes\*.xml"
        add-to-tour-xml $scenesFolder
        Add-Content $tourFile '</krpano>'
    }
}

function generate-brands-grid {
    # Generate the HTML files with the logos in a grid
    Write-Verbose 'Generate Brands HTML files' -Verbose
    [xml]$xml = get-content $config
    $tour = $xml.tour.brand
    $param1 = 0
    $param2 = 0
    $tempfile = "$dir\..\.src\html\index.temp"
    $brandsfile = "$dir\brands\index.html"
    $morebrandsfile = "$dir\brands\more.html"
    add-folder "$dir\brands"
    New-Item -ItemType File $tempfile -Force
    foreach ($brand in $tour) {
        $brand_name = $brand.id           
        Add-Content $tempfile ('                <article class="one-fifth" style="transform:translate(' + $param1 + 'px,' + $param2 + 'px); -webkit-transform: translate3d(' + $param1 + 'px,' + $param2 + 'px,0px);"><a href="../' + $($brand.id) + '/brand.html" class="project-meta" title="Click me"><img src="./img/logos/' + $($brand.id) + '.jpg" alt="' + $($brand.name) + '"/></a><a href="../' + $($brand.id) + '/brand.html" class="project-meta"><h5 class="title">' + $($brand.name) + '</h5></a></article>')
        $param1 = $param1 + 192
        if ($param1 -eq 960) {
            $param1 = 0
            $param2 = $param2 + 220
        }
    }
    $template_content = Get-Content $dir\..\.src\html\brands_index_template.html
    $brands_content = Get-Content $tempfile
    $template_content | foreach $_ {
        if ($_ -match 'ADDCONTENT' ) {
            $brands_content
        } elseif ($_ -match 'PARAM3') {
            ($_).replace('PARAM3',$param2)
        } else {
            $_
        }
    } | Set-Content $brandsfile
    Remove-Item $tempfile -Force
    Get-Content $brandsfile |
    # Now we need to create more.html, which is the same as index.html but changing the the links to more_brands.html
    foreach { ($_).replace('brand.html','more_brands.html') } | 
    Out-File -Encoding utf8 $morebrandsfile
}

# This function is used by the backwards compatibility code
function add-code {
    # Remove tour_clean.xml
    Remove-Item $clean
    # Add code to tour
    Add-Content $origin (get-content $code)
    # Remove </krpano> from tour.xml
    Get-Content $origin | Where-Object {$_ -notmatch '</krpano>'} | Set-Content $temp
    Add-Content $temp "</krpano>"
    Move-Item -force $temp $origin
    # Remove ^M from tour.xml and save as tour_clean.xml
    Get-Content $origin | Foreach {$_.TrimEnd()} | Set-Content $clean
    # Copy tour_clean.xml as tour.xml
    Copy-Item $clean $origin
}

function fix-mercedes {
    cp $dir\mercedes_benz\mercedes_benz_m_class.html $dir\mercedes_benz\mercedes_benz_ml_class.html
    # Delete Mercedes ML from index.html files
    Get-Content $dir\index.html | Where-Object {$_ -notmatch 'benz_ml'} | Set-Content $dir\index_out.html
    Remove-Item $dir\index.html
    Rename-Item $dir\index_out.html $dir\index.html
    Get-Content $dir\mercedes_benz\index.html | Where-Object {$_ -notmatch 'benz_ml'} | Set-Content $dir\mercedes_benz\index_out.html
    Remove-Item $dir\mercedes_benz\index.html
    Move-Item $dir\mercedes_benz\index_out.html $dir\mercedes_benz\index.html
    # Add code for scene 'mercedes_bend_ml_class' to tour.xml and tour_clean.xml
    # but only if it hasn't been added already
    $check_content = dir "$dir\mercedes_benz\files\tour.xml" | sls ml_class
    if ($check_content.Length -eq 0) {
        $origin =  "$dir\mercedes_benz\files\tour.xml"
        $temp = "$dir\mercedes_benz\files\temp.xml"
        $clean =  "$dir\mercedes_benz\files\tour_clean.xml"
        $code = "$dir\.backcomp\mercedes\mercedes_benz_ml_class.xml"
        add-code
    }
    Write-Verbose 'Backward compatibility applied to Mercedes-Benz' -Verbose
}

function fix-ford {
    # Create html files without 'ford' at the begining
    $htmlFiles = dir $dir\ford\ford_*.html
    foreach( $html in $htmlFiles ) {
        $newname1 = $html.BaseName.Split('_')[1]
        $newname2 = $html.BaseName.Split('_')[2]
        $newname3 = $html.BaseName.Split('_')[3]
        if ( $newname1.count -gt 0 ) { $newname = $html.BaseName.Split('_')[1] + $html.Extension }
        if ( $newname2.count -gt 0 ) { $newname = $html.BaseName.Split('_')[1] + "_" + $html.BaseName.Split('_')[2] + $html.Extension }
        if ( $newname3.count -gt 0 ) { $newname = $html.BaseName.Split('_')[1] + "_" + $html.BaseName.Split('_')[2] + "_" + $html.BaseName.Split('_')[3] + $html.Extension }
        Copy-Item $html.FullName $dir\ford\$newname 
    }
    # Ford Kuga
    cp $dir\ford\ford_kuga.html $dir\ford\cougar.html
    # No need to delete Cougart from index.html files as only html files starting with 'ford_' are listed
    # Add code for scene 'cougar' to tour.xml and tour_clean.xml but ONLY if it hasn't been added already
    $check_content = dir "$dir\ford\files\tour.xml" | sls "`"cougar`""
    if ($check_content.Length -eq 0) {
        $origin =  "$dir\ford\files\tour.xml"
        $temp = "$dir\ford\files\temp.xml"
        $clean =  "$dir\ford\files\tour_clean.xml"
        $code = "$dir\.backcomp\ford\cougar.xml"
        add-code
    }
    Write-Verbose 'Backward compatibility applied to Ford' -Verbose
}

function fix-renault {
    # Renault Scenic
    cp $dir\renault\renault_scenic.html $dir\renault\renault_scenic_scenic.html
    # Delete Renault Scenic Scenic from index.html files
    Get-Content $dir\index.html | Where-Object {$_ -notmatch 'renault_scenic_scenic'} | Set-Content $dir\index_out.html
    Remove-Item $dir\index.html
    Rename-Item $dir\index_out.html $dir\index.html
    Get-Content $dir\renault\index.html | Where-Object {$_ -notmatch 'renault_scenic_scenic'} | Set-Content $dir\renault\index_out.html
    Remove-Item $dir\renault\index.html
    Move-Item $dir\renault\index_out.html $dir\renault\index.html
    # Add code for scene 'renault_scenic_scenic' to tour.xml and tour_clean.xml but ONLY if it hasn't been added already
    $check_content = dir "$dir\renault\files\tour.xml" | sls renault_scenic_scenic
    if ($check_content.Length -eq 0) {
        $origin =  "$dir\renault\files\tour.xml"
        $temp = "$dir\renault\files\temp.xml"
        $clean =  "$dir\renault\files\tour_clean.xml"
        $code = "$dir\.backcomp\renault\renault_scenic_scenic.xml"
        add-code
    }
    # Renault Grand Scenic
    cp $dir\renault\renault_grand_scenic.html $dir\renault\renault_scenic_grand_scenic.html
    # Delete Renault Scenic Grand Scenic from index.html files
    Get-Content $dir\index.html | Where-Object {$_ -notmatch 'renault_scenic_grand_scenic'} | Set-Content $dir\index_out.html
    Remove-Item $dir\index.html
    Rename-Item $dir\index_out.html $dir\index.html
    Get-Content $dir\renault\index.html | Where-Object {$_ -notmatch 'renault_scenic_grand_scenic'} | Set-Content $dir\renault\index_out.html
    Remove-Item $dir\renault\index.html
    Move-Item $dir\renault\index_out.html $dir\renault\index.html
    # Add code for scene 'renault_scenic_grand_scenic' to tour.xml and tour_clean.xml but ONLY if it hasn't been added already
    $check_content = dir "$dir\renault\files\tour.xml" | sls renault_scenic_grand_scenic
    if ($check_content.Length -eq 0) {
        $origin =  "$dir\renault\files\tour.xml"
        $temp = "$dir\renault\files\temp.xml"
        $clean =  "$dir\renault\files\tour_clean.xml"
        $code = "$dir\.backcomp\renault\renault_scenic_grand_scenic.xml"
        add-code
    }
    Write-Verbose 'Backward compatibility applied to Renault' -Verbose
}

function fix-chevrolet-left {
    # Change html5:"prefer" to html5:"fallback" in all the cars HTML files
    Get-ChildItem $dir\chevrolet_left\ -Recurse -Filter "*.html" -Exclude "index.html","brand.html","more_brands.html" |
    foreach {
        Get-Content $_.FullName |
            foreach { ($_).replace('html5:"prefer"','html5:"fallback"') } |
                Set-Content "$($_.FullName).temp"
            Move-Item -Force "$($_.FullName).temp" $_.FullName
    }
    Write-Verbose 'Fix applied to Chevrolet Left' -Verbose
}