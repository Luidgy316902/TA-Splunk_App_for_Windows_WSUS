# Splunk App for Windows WSUS
Welcome to the Splunk App for Windows WSUS.  Feel free to contribute or open isues if you have problems.

## Indexes
* wsus

## SourceTypes
* wsus:synchronizationreport
* wsus:event
* wsus:update


## Reports
* WSUS - Synchronization Reports
* WSUS - Event History

## Debugging
In order to see if any of the underlying powershell scripts are blowing up or having issues simply run the following search from your splunk server.

```
    index="_internal" log_level=ERROR host="wsusserv-001.attlocal.net" sourcetype=splunkd
```

### Running Script interactively
If you want to test the scripts that pull data and ensure they are working right simply setup the environment variables needed and then run the script.  It should not blow up and be idempotent
$SplunkHome = 'C:\Program Files\SplunkUniversalForwarder\'
.\Get-WSUSSynchronizationReports.ps1

## Contributing

1. Fork it ( https://github.com/TraGicCode/TA-Splunk_App_for_Windows_WSUS/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request