Function Get-CheckpointFromFile {
    Param(
        $File
    )
    try
    {
        Get-Content -Path $File -ErrorAction Stop
    }
    catch
    {
        Write-Error('{0:MM/dd/yyyy HH:mm:ss} GMT - {1} {2}' -f (Get-Date).ToUniversalTime(), "Could not get position from position file: ", $_.Exception.Message)
        exit
    }
}
