Function Ensure-CheckpointFile {
    Param(
        $File,
        [String]$InitialCheckpointValue
    )

    if(!(Test-Path $File))
    {
        try
        {
            Set-Content -Value "$InitialCheckpointValue" -Path $File -ErrorAction Stop
        }
        catch
        {
            Write-Error('{0:MM/dd/yyyy HH:mm:ss} GMT - {1} {2}' -f (Get-Date).ToUniversalTime(), "Could not create position file: ", $_.Exception.Message)
            exit
        }
    }

}
