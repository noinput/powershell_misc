$customerName = ""

# SQL config
$sqlServer = ""
$sqlDb = "sensiodb1"
$sqlQuery = "select TOP 1 lastReportTimeUtc from controllers order by lastReportTimeUtc DESC"

# SMTP Config
$SMTPServer = ""
$SMTPPort = "25"
$From = ""
$To = "user1@xxx.cna; user2@xxx.cna"
$Subject = "$customerName - Unity is DOWN!!!"

while ($true)
{
    # console timestamp
    $timestampCli = Get-Date -Format "dd.MM.yyyy HH:mm:ss"

    # query database
    $sqlData = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDb -Query $sqlQuery

    # Save local time and lastReporttime as UTC
    $timeNowUTC = (Get-Date).ToUniversalTime()
    $timeThen = $sqlData.Item("lastReportTimeUtc")

    # calculate time difference in seconds
    $dt = New-TimeSpan -Start $timeThen -End $timeNowUTC
    $secondsSinceLastReport = [int]$dt.TotalSeconds

    # treshhold in seconds before a "system down" is triggered. (600 = 10 minutes)
    $timeTreshold = 1800

    Write-Host "[$timestampCli]" -NoNewLine
    # check if seconds since last report (from a Controller) is equal or greater than the treshold
    if ($secondsSinceLastReport -ge $timeTreshold) {
        
        # create mail body
        $mailBody = "
        Most recent report from a Controller was $secondsSinceLastReport seconds ago<br />
        <br />Last update was at $timeThen UTC
        <br />Time Now UTC: $timeNowUTC"

        Write-Host " [DOWN] " -ForegroundColor Red -NoNewline
        Write-Host "Last update on Controllers was $secondsSinceLastReport seconds ago..Sending mail and pausing script.."
        
        Send-MailMessage -From $From -to $To -Subject $Subject -Body $mailBody -BodyAsHtml -SmtpServer $SMTPServer -Port $SMTPPort
        
        Read-Host "Press <ENTER> to restart the script..."
    
    } else {
        Write-Host " [OK] " -ForegroundColor Green -NoNewline
        Write-Host "Last update on Controllers was $secondsSinceLastReport seconds ago.."
    }
    Start-Sleep -Seconds 60
}


    






