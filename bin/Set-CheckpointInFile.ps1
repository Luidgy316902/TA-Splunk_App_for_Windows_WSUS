Function Set-CheckpointInFile {
    Param(
        $File,
        [String]$CheckpointValue
    )

    try
    {
        Set-Content -Value "$CheckpointValue" -Path $File -ErrorAction Stop
    }
    catch
    {
        Write-Error('{0:MM/dd/yyyy HH:mm:ss} GMT - {1} {2}' -f (Get-Date).ToUniversalTime(), "Could not Update position in position file: ", $_.Exception.Message)
        exit
    }
}
