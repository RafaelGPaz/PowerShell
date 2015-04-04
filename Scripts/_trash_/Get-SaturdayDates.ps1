clear-host
#For each month
(1..12) | foreach { 
    $month = $_
    (get-date $month/2013 -Format MMMM)
    $no_days = [DateTime]::DaysInMonth(2013, $month)
    # For each day in each month
    (1..$no_days) | foreach {
        $day = $_ 
        $date = $(get-date $day/$month/2014)
        # If it's Saturday
        if ($date.DayOfWeek -eq "Saturday") {
            write-host "  " $date.tostring("yyyy-MM-dd")
        } 
    }
}
write-host eof
