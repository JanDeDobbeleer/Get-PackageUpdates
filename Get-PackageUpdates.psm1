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
    $groupedModules = Get-Module -ListAvailable | Where-Object {$_.repositorysourcelocation} | Group-Object Name
    # group and keep highest version
    $gallery = @()
    foreach ($moduleGroup in $groupedModules) {
        $moduleToKeep = $moduleGroup.Group[0]
        foreach ($module in $moduleGroup.Group) {
            if ($module.version -gt $moduleToKeep.version) {
                $moduleToKeep = $module
            } 
        }
        Write-Host "$($moduleToKeep.Name) $($moduleToKeep.Version)"
        $gallery += $moduleToKeep 
    }    
    foreach ($module in $gallery) {
        #find the current version in the gallery
        Try {
            $online = Find-Module -Name $module.name -Repository PSGallery -ErrorAction Stop
            #compare versions
            if ($online.version -gt $module.version) {
                Write-Host "$($module.name): Online - $($online.version), local - $($module.version)"
                $ps_count++
            } 
        }
        Catch {
            # Who cares, not found
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

