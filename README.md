# Get-PackageUpdates

Print Chocolatey and PSGallery updates in your PowerShell session

## Installation

Add the following lines to your $profile:

    Import-Module Get-PackageUpdates
    Write-PackageUpdates

Create a shortcut under shell:startup that includes the following line:

    C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -Command "Save-PackageUpdates"

This will start a PS session at startup (logon) which will get and save the available updates.
That way it can be printed when you start a new session once it is available.

Inspired by and partially stolen from [here](http://jdhitsolutions.com/blog/powershell/5441/check-for-module-updates/)
