<#
.Synopsis
    Build Script
#>

[CmdletBinding()]
Param(
)

Set-StrictMode -Version Latest

# Includes

# Script Variables
$BuildArtifactsFolder = "$BuildRoot\.buildartifacts"

#=================================================================================================
# Synopsis: Performs a Clean of all build artifacts
#=================================================================================================
Task Clean {
    If (Test-Path -Path $BuildArtifactsFolder)
	{
		Remove-Item $BuildArtifactsFolder -Force -Recurse
	}

    New-Item -Path $BuildArtifactsFolder -ItemType Directory | Out-Null
}

#=================================================================================================
# Synopsis: Package Splunk App for uploading
#=================================================================================================
Task Package {
    & 7z.exe a -ttar -xr!"$BuildArtifactsFolder" -xr!".git" -xr!".Build.ps1" -xr!"Invoke-Build.ps1" "$BuildArtifactsFolder\TA-Splunk_App_for_Windows_WSUS.tar"  ..\TA-Splunk_App_for_Windows_WSUS
}

Task . Clean, Package, {
}