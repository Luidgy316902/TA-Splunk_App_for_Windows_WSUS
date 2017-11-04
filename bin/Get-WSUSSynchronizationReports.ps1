#EventCategory   : SynchronizationCompletion
#Error           : UssCommunicationError
#ErrorText       : WebException: The remote name could not be resolved: 'fe2.update.microsoft.com'
#                  at System.Net.HttpWebRequest.GetRequestStream(TransportContext& context)
#                     at System.Net.HttpWebRequest.GetRequestStream()
#                     at System.Web.Services.Protocols.SoapHttpClientProtocol.Invoke(String methodName, Object[] parameters)
#                     at Microsoft.UpdateServices.ServerSyncWebServices.ServerSync.ServerSyncProxy.GetAuthConfig()
#                     at Microsoft.UpdateServices.ServerSync.ServerSyncLib.InternetGetServerAuthConfig(ServerSyncProxy proxy, WebServiceCommunicationHelper webServiceHelper)
#                     at Microsoft.UpdateServices.ServerSync.ServerSyncLib.Authenticate(AuthorizationManager authorizationManager, Boolean checkExpiration, ServerSyncProxy proxy, Cookie cookie, WebServiceCommunicationHelper webServiceHelper)
#                     at Microsoft.UpdateServices.ServerSync.CatalogSyncAgentCore.SyncConfigUpdatesFromUSS()
#                     at Microsoft.UpdateServices.ServerSync.CatalogSyncAgentCore.ExecuteSyncProtocol(Boolean allowRedirect)
#Administrator   : NT AUTHORITY\NETWORK SERVICE
#UpdateErrors    : {}
#WsusEventId     : SynchronizationCompletedFailure
#WsusEventSource : Server
#Id              : 196c5151-c355-484d-a99b-fbb7da39f490
#CreationDate    : 10/26/2017 11:41:44 AM
#Message         : Synchronization failed. Reason: The remote name could not be resolved: 'fe2.update.microsoft.com'.
#IsError         : True
#ErrorCode       : -2146233079
#Row             : Microsoft.UpdateServices.Internal.DatabaseAccess.EventHistoryTableRow


# EventCategory   : SynchronizationCompletion
# Error           : NotApplicable
# ErrorText       : 
# Administrator   : NT AUTHORITY\NETWORK SERVICE
# UpdateErrors    : {}
# WsusEventId     : SynchronizationCompletedSuccess
# WsusEventSource : Server
# Id              : 37490570-3fae-412c-bd56-c0d8dab457fc
# CreationDate    : 10/26/2017 5:06:41 AM
# Message         : Synchronization completed successfully.
# IsError         : False
# ErrorCode       : 0
# Row             : Microsoft.UpdateServices.Internal.DatabaseAccess.EventHistoryTableRow



Function Create-WSUSSynchronizationReport($startEvent, $endEvent)
{
    $result = $null
    if ($endEvent.IsError) {
        $result = 'Failed'
    } else {
        $result = 'Succeeded'
    }
    # I need something unique to handle duplicates so i'm going to pick the last event id
    return [PSCustomObject]@{
                  Id = $endEvent.Id
                  Error = $endEvent.ErrorText
                  User = $endEvent.Administrator
                  Started = $startEvent.CreationDate
                  Finished = $endEvent.CreationDate
                  Result = $result
                  Type = 'unknown'
                  NewUpdates = 'unknown'
                  RevisedUpdates = 'unknown'
                  ExpiredUpdates = 'unknown'
              }
}

$wsus = Get-WSUSServer
$db = $wsus.GetDatabaseConfiguration().CreateConnection()
$db.connect()
# $db
# $result = $db.GetDataSet('select * from INFORMATION_SCHEMA.TABLES',[System.Data.CommandType]::Text)
# $result.Tables
$EventIds = @()
$reader = $db.ExecuteReader("SELECT * FROM [tbEventInstance] WHERE [EventNamespaceID] = '2' AND [EventId] IN ('381', '382', '384', '386', '387') ORDER BY [TimeAtTarget] ASC", [System.Data.CommandType]::Text)
while ($reader.Read())
{
   $EventIds += $reader.GetValue(0)
}
$reader.Close()

$CombinedEvents = @()
if(($EventIds.Count % 2))
{
    # knock off the last odd one
    $EventIds = $EventIds[0..($EventIds.Length-2)]
}

$temp = @()
For ($i=0; $i -lt $EventIds.Count; $i++) 
{
    $temp += (Get-WsusServer).GetSubscriptionEvent($EventIds[$i])
    if ($temp.Count -eq 2)
    {
        $CombinedEvents += Create-WSUSSynchronizationReport -startEvent $temp[0] -endEvent $temp[1]
        $temp = @()
    }
}

ForEach($combinedEvent in $CombinedEvents) 
{
    Write-Output $combinedEvent
}
