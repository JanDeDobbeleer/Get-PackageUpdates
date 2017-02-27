[cmdletbinding()]
Param()

<#
Print update info using $env:ChocoUpdatesCount and $env:PSUpdatesCount and the following logic to your $profile:

Import-Module Get-PackageUpdates
Write-PackageUpdates

Open Explorer under shell:startup and create a shortcut that includes the following line:
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -Command "Save-PackageUpdates"
#>

function Write-PackageUpdate {
    param(
        [int]
        $count,
        [string]
        $environment
    )

    if ($count -gt 0) {
        Write-Host "$count $environment packages can be updated"
    }
}

function Write-PackageUpdates {
    if (Test-Path "~\.updateinfo") {
        $updateInfo = Get-Content '~\.updateInfo' | ConvertFrom-Json
        if ($updateInfo) {
            Write-PackageUpdate -count $updateInfo.ChocoUpdatesCount -environment 'Chocolatey'
            Write-PackageUpdate -count $updateInfo.PSUpdatesCount -environment 'PowerShell'
        }
    }    
}

function Get-PackageUpdates {
    # Check for Chocolatey updates
    $choco_count = 0
    $ps_count = 0
    $choco_outdated = choco outdated
    if ("$choco_outdated" -match '([0-9]*) package\(s\)') {
        $choco_count = $Matches[1]
    }

    # Check for PSGallery updates
    $modules = Get-Module -ListAvailable
    #group to identify modules with multiple versions installed
    $g = $modules | Group-Object name -NoElement | Where-Object count -gt 1
    $gallery = $modules.where({$_.repositorysourcelocation})
    foreach ($module in $gallery) {
        #find the current version in the gallery
        Try {
            $online = Find-Module -Name $module.name -Repository PSGallery -ErrorAction Stop
        }
        Catch {
            # Who cares, not found
        }

        #compare versions
        if ($online.version -gt $module.version) {
            $ps_count++
        } 
    } #foreach

    return New-Object -TypeName PSObject -Property @{ 
        ChocoUpdatesCount = $choco_count 
        PSUpdatesCount = $ps_count 
    }
}

function Save-PackageUpdates {
    (Get-PackageUpdates) | ConvertTo-Json | Out-File '~\.updateInfo'
}

