# Includes
. "$SplunkHome\etc\apps\TA-Splunk_App_for_Windows_WSUS\bin\Merge-Object.ps1"
. "$SplunkHome\etc\apps\TA-Splunk_App_for_Windows_WSUS\bin\Ensure-CheckpointFile.ps1"
. "$SplunkHome\etc\apps\TA-Splunk_App_for_Windows_WSUS\bin\Get-CheckpointFromFile.ps1"
. "$SplunkHome\etc\apps\TA-Splunk_App_for_Windows_WSUS\bin\Set-CheckpointInFile.ps1"

# Checkpoint File
$CheckpointFile = Join-Path -Path $SplunkHome -ChildPath "etc\apps\TA-Splunk_App_for_Windows_WSUS\bin\checkpoint-wsus-synchronizationreport.txt"
$CheckpointDateTimeFormat = "MM/dd/yyyy HH:mm:ss.fff"
$InitialCheckpointValue = [DateTime]::MinValue.ToString($CheckpointDateTimeFormat) + " GMT"

Ensure-CheckpointFile -File $CheckpointFile -InitialCheckpointValue $InitialCheckpointValue
$CurrentCheckpoint = Get-CheckpointFromFile -File $CheckpointFile


$WsusServer = Get-WsusServer

$SynchronizationHistory = $WsusServer.GetSubscription().GetSynchronizationHistory([DateTime]::Parse($CurrentCheckpoint).AddSeconds(1), [DateTime]::UtcNow) | Select-Object -Property *
If($SynchronizationHistory.Count -eq 0)
{
    exit
}

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
            $UpdateStats.ExpiredUpdates++
        }
        If($Update.PublicationState -eq "Published")
        {
            $UpdateStats.NewUpdates++
        }
    }
    Merge-Object -Base $SynchronizationHistoryEntry -Additional $UpdateStats
}

# Synchronizations returned from above are from newest to oldest in the array
$UpdatedCheckpointValue = $SynchronizationHistory[0].EndTime.ToString($CheckpointDateTimeFormat) + " GMT"
Set-CheckpointInFile -File $CheckpointFile -CheckpointValue $UpdatedCheckpointValue
