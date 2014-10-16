function check-krpano {
    clear-Host
    $geturl=Invoke-WebRequest http://krpano.com/news
    write-host "==========="
    write-host -ForegroundColor Yellow "Krpano News"
    write-host "==========="
    # Search for links (fastest 2 secs)
    $news = ($geturl.Links |Where href -match '\#news\d+' | where class -NotMatch 'moreinfo+' )
    # Search for divs in body (slowest 29 secs)
    #$news = ($geturl.ParsedHtml.body.getElementsByTagName('div') | Where {$_.getAttributeNode('class').Value -eq 'newstitle' } )
    # Search for divs in all elements (slow 10 secs)
    #$news = ($geturl.AllElements | ? { $_.Class -eq 'newstitle' } )
    
    #Select-Object is a little bit slower than getting the first 5 items for the array
    #$news.outertext | Select-Object -First 5
    ($news)[0..4].outerText
}

#Measure-Command {
check-krpano
#}
