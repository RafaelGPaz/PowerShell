[datetime]$birthday = "12/22/2012 03:27:00"
$span = [datetime]::Now - $birthday
$age = New-Object DateTime -ArgumentList $Span.Ticks
write-host "Laura was born the" $age
Write-Host "And she is" $($age.Year -1) Years $($age.Month -1) Months $age.Day "days"
#Write-Host "And she is" $($age.Year -1) Years $($age.Month -1) Months $age.Day "days" ($age.Hour) "hours" ($age.Minute) "minutes" ($age.second) "seconds" 