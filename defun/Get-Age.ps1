[datetime]$birthday = "12/22/2012 03:27:00"
$span = [datetime]::Now - $birthday
Write-Host $span.Days
$age = New-Object DateTime -ArgumentList $Span.Ticks
write-host $age
Write-Host "My daughter's age is:" $($age.Year -1) Years $($age.Month -1) Months $age.Day "days" ($age.Hour) "hours" ($age.Minute) "minutes" ($age.second) "seconds" 