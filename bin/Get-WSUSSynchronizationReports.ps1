. $SplunkHome/etc/system/bin/Merge-Object.ps1


$WsusServer = Get-WsusServer
# The select-object essentially creates a new object for us
$SynchronizationHistory = $WsusServer.GetSubscription().GetSynchronizationHistory() | Select-Object -Property *
ForEach($SynchronizationHistoryEntry in $SynchronizationHistory)
{
    $UpdateScope = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateScope
    $UpdateScope.FromArrivalDate = $SynchronizationHistoryEntry.StartTime
    $UpdateScope.ToArrivalDate = $SynchronizationHistoryEntry.EndTime
    $Updates = $WsusServer.GetUpdates($UpdateScope)
    $UpdateStats = [PSCustomObject]@{
        NewUpdates = 0
        RevisedUpdates = 0
        ExpiredUpdates = 0
    }
    ForEach($Update in $Updates)
    {
        If($Update.PublicationState -eq "Expired")
        {
            $UpdateStats.ExpiredUpdateCountForReport++
        }
        If($Update.PublicationState -eq "Published")
        {
            $UpdateStats.NewUpdatesCountForReport++
        }
    }
    Merge-Object -Base $SynchronizationHistoryEntry -Additional $UpdateStats
}
