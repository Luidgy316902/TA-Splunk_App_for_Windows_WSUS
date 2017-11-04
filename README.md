# Eventtypes
Allow for categorize and labeling events
- Approved Updates
- Declined Updates

- Critical Updates
etc..


# Notes
## (Get-WsusServer).GetUpdates()
Returns all updates wsus knows about including expired

Example of Output of an update
```
UpdateServer                       : Microsoft.UpdateServices.Internal.BaseApi.UpdateServer
Id                                 : Microsoft.UpdateServices.Administration.UpdateRevisionId
Title                              : Cumulative Update for Windows Server 2016 (1709) for x64-based Systems (KB4043961)
Description                        : A security issue has been identified in a Microsoft software product that could affect your system. You can help protect your system by installing this update from Microsoft. For a complete listing of the issues that are included in
                                     this update, see the associated Microsoft Knowledge Base article. After you install this update, you may have to restart your system.
LegacyName                         : KB4043961-Windows10Rs3Server-RTM-X64-TSL-World
MsrcSeverity                       : Critical
KnowledgebaseArticles              : {4043961}
SecurityBulletins                  : {}
AdditionalInformationUrls          : {http://support.microsoft.com/help/4043961}
ReleaseNotes                       :
UpdateClassificationTitle          : Security Updates
CompanyTitles                      : {Microsoft}
ProductTitles                      : {Windows Server 2016}
ProductFamilyTitles                : {Windows}
IsLatestRevision                   : True
HasEarlierRevision                 : False
Size                               : 0
CreationDate                       : 10/17/2017 5:00:03 PM
ArrivalDate                        : 10/24/2017 3:35:50 AM
UpdateType                         : Software
PublicationState                   : Published
InstallationBehavior               : Microsoft.UpdateServices.Administration.InstallationBehavior
UninstallationBehavior             : Microsoft.UpdateServices.Administration.InstallationBehavior
IsBeta                             : False
HasStaleUpdateApprovals            : False
IsApproved                         : False
IsDeclined                         : False
DefaultPropertiesLanguage          :
HasLicenseAgreement                : False
RequiresLicenseAgreementAcceptance : False
State                              : NotNeeded
HasSupersededUpdates               : False
IsSuperseded                       : False
IsWsusInfrastructureUpdate         : False
IsEditable                         : False
UpdateSource                       : MicrosoftUpdate
```

## Get-WsusUpdate
Returns all updates wuss knows about exclusing expired.  This essentially returns the above old stuff + more

Example Output of an update
```
Update                             : Microsoft.UpdateServices.Internal.BaseApi.Update # Link below
Classification                     : Security Updates
InstalledOrNotApplicablePercentage : 0
Approved                           : NotApproved
ComputersWithErrors                : 0
ComputersNeedingThisUpdate         : 0
ComputersInstalledOrNotApplicable  : 0
ComputersWithNoStatus              : 1
MsrcNumbers                        : {}
Removable                          : True
RestartBehavior                    : Never restarts
MayRequestUserInput                : False
MustBeInstalledExclusively         : False
LicenseAgreement                   : This update does not have Microsoft Software License Terms.
Products                           : {Windows Server 2016}
UpdatesSupersedingThisUpdate       : {None}
UpdatesSupersededByThisUpdate      : {None}
LanguagesSupported                 : {all}
UpdateId                           : 0d02abc5-41ec-4768-8419-8487fa2e322b
```

```
UpdateServer                       : Microsoft.UpdateServices.Internal.BaseApi.UpdateServer
Id                                 : Microsoft.UpdateServices.Administration.UpdateRevisionId
Title                              : Cumulative Update for Windows Server 2016 (1709) for x64-based Systems (KB4043961)
Description                        : A security issue has been identified in a Microsoft software product that could affect your system. You can help protect your system by installing this update from Microsoft. For a complete listing of the issues that are included in
                                     this update, see the associated Microsoft Knowledge Base article. After you install this update, you may have to restart your system.
LegacyName                         : KB4043961-Windows10Rs3Server-RTM-X64-TSL-World
MsrcSeverity                       : Critical
KnowledgebaseArticles              : {4043961}
SecurityBulletins                  : {}
AdditionalInformationUrls          : {http://support.microsoft.com/help/4043961}
ReleaseNotes                       :
UpdateClassificationTitle          : Security Updates
CompanyTitles                      : {Microsoft}
ProductTitles                      : {Windows Server 2016}
ProductFamilyTitles                : {Windows}
IsLatestRevision                   : True
HasEarlierRevision                 : False
Size                               : 0
CreationDate                       : 10/17/2017 5:00:03 PM
ArrivalDate                        : 10/24/2017 3:35:50 AM
UpdateType                         : Software
PublicationState                   : Published
InstallationBehavior               : Microsoft.UpdateServices.Administration.InstallationBehavior
UninstallationBehavior             : Microsoft.UpdateServices.Administration.InstallationBehavior
IsBeta                             : False
HasStaleUpdateApprovals            : False
IsApproved                         : False
IsDeclined                         : False
DefaultPropertiesLanguage          :
HasLicenseAgreement                : False
RequiresLicenseAgreementAcceptance : False
State                              : NotNeeded
HasSupersededUpdates               : False
IsSuperseded                       : False
IsWsusInfrastructureUpdate         : False
IsEditable                         : False
UpdateSource                       : MicrosoftUpdate
```


# WSUS Synchronization Reports WIP
# DONE: Filter out A Subscription has been modified. Message Template or eventID 389.
# TODO: Okay i have the report but how can i get the info in the report like what updates expired and what updates are new etc.
select e.EventID,
       e.EventNamespaceID,
	   StateID,
	   SeverityID,
	   LogLevel,
	   DisplayNameString,
	   EventInstanceID,
	   EventSourceID,
	   TimeAtTarget,
	   Win32HResult,
	   EventOrdinalNumber,
	   ComputerID,
	   emt.MessageTemplate AS "Synchronization Status"
	   from tbEvent as e
inner join tbEventNamespace as n on n.EventNamespaceID = e.EventNamespaceID 
inner join tbEventInstance as ei on ei.EventID = e.EventID AND ei.EventNamespaceID = e.EventNamespaceID
INNER JOIN [tbEventMessageTemplate] as emt on emt.EventID = e.EventID AND emt.EventNamespaceID = e.EventNamespaceID
where e.EVENTID IN ('381', '382', '384', '386', '387')

######
# Pass an event id guid here
# (Get-WsusServer).GetSubscriptionEvent("37490570-3FAE-412C-BD56-C0D8DAB457FC")



#######
# Get the last sync info (start and end times)
$lastSync = (Get-WsusServer).GetSubscription().GetLastSynchronizationInfo()
 
# Create an updatescope object
$UpdateScope = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateScope
 
# Set the start time
$UpdateScope.FromArrivalDate = $lastSync.StartTime
# Set the end time
$UpdateScope.ToArrivalDate = $lastSync.EndTime
 
# Invoke the getupdates method using the update scope object
$SyncUpdates = (Get-WsusServer).GetUpdates($UpdateScope)

########
# How to query WSUS SQL Database from powershell
$wsus = Get-WSUSServer
$wsus |  Get-Member -Name GetDatabaseConfiguration
$db = $wsus.GetDatabaseConfiguration().CreateConnection()
$db.connect()
$db
#$result = $db.GetDataSet('select * from INFORMATION_SCHEMA.TABLES',[System.Data.CommandType]::Text)
#$result.Tables

# $result_ = $db.GetDataSet("select * FROM tbEventInstance WHERE EventNamespaceID = '2' AND EVENTID IN ('381', '382', '384', '386', '387', '389')",[System.Data.CommandType]::Text)
# $cmd = $db.CreateCommand("select * FROM tbEventInstance WHERE EventNamespaceID = '2' AND EVENTID IN ('381', '382', '384', '386', '387', '389')", [System.Data.CommandType]::Text)
$reader = $db.ExecuteReader("select * FROM tbEventInstance WHERE EventNamespaceID = '2' AND EVENTID IN ('381', '382', '384', '386', '387', '389')", [System.Data.CommandType]::Text)
while ($reader.Read())
{
   $name = $reader.GetValue(0);
   $cRate = $reader.GetValue(1);
   Write-Host $name,"(",$cRate,")"
}
$reader.Close()