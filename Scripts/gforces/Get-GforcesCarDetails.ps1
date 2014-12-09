$paths = $(ll -path "E:\virtual_tours\gforces\cars\" -Exclude ".no_scenes", ".src", "brands", "shared", "crossdomain.xml" ).basename
$item =
foreach ($path in $paths){
    $countrycode = ($path -split "_")[0]
    $make = ($path -split "_")[-3]
    $model = ($path -split "_")[-2]
    $description = ($path -split "_")[-1]

    new-object psobject -property  @{
        Countrycode = $countrycode;        
        Make = $make
        Model = $model
        Description = $description
        } 

  } 
  #$item
  $item | select -Property Countrycode,Make,Model,Description 
