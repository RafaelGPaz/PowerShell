    # ---------- HASH TABLE METHOD ----------
    #$Tours = $null
    #$Tours = @{}
    #$ToursArray | ForEach-Object  {
    #    $tourName = $(Get-Variable $_).Name
    #    $tourScenes = $(Get-Variable $_).Value
    #    $Tours.add($tourName,$tourScenes)
    #}   
    # Print Tours information from the hash table  
    #write-verbose "Number of Tours: $($Tours.count)"
    #foreach ($pair in  $Tours.GetEnumerator()) {
    #    Write-Verbose "  $($pair.key) : $($pair.Value)"
    #}

    # Print Tours information from the arrays
    #Write-Verbose "Virtual Tours list: ($($ToursArray.count))"
    #$ToursArray | ForEach-Object {
    #    Write-Verbose "  $_ : $($(Get-Variable $_).Value)"
    #}