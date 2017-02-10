function monitorService
{  
    [CmdletBinding()]
    param (
        [string] $serviceName
        , [string] $serverName
    )
    $item = @()
    $item += New-Object -type PSCustomObject -Property @{
        'serviceName' = $serviceName
        'serverName' = $serverName
    }
    return $item
}

$serviceList = @()
$serviceList += monitorService "sqlservr" "sql2014"
$serviceList += monitorService "sqlservr" "sql2008"  
$serviceList += monitorService "database" "fakeserver" 

$statusObject = @()

foreach($service in $serviceList) {
    $processCheck = $(get-process -computername $($service.serverName) | where-object { $_.processname -eq $($service.serviceName) }).ProcessName
    if($processCheck -eq $service.serviceName) {
        write-host "$($service.serviceName) is running on $($service.serverName)!" -ForegroundColor white -BackgroundColor Green
        $serverStatus = New-Object -type PSCustomObject -Property @{
            'serviceName' = $($service.serviceName)
            'serverName' = $($service.serverName)
            'serviceStatus' = 'Online'
        }
        $statusObject += $serverStatus

    } else {
        write-host "$($service.serviceName) is NOT running on $($service.serverName)!" -ForegroundColor Red -BackgroundColor Black
        $serverStatus = New-Object -type PSCustomObject -Property @{
            'serviceName' = $($service.serviceName)
            'serverName' = $($service.serverName)
            'serviceStatus' = 'Offline'
        }
        $statusObject += $serverStatus
    }
}
$statusObject | ConvertTo-Json