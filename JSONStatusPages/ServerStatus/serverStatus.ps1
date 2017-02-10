<# server status #>
$adservers = get-adcomputer -filter * -searchbase "ou=Servers,dc=contoso,dc=com"
$servers = @()
$servers += $adservers.DNSHostName
$statusObject = @()
$failCheck = 0
$lastCheck = get-date -f 'H:mm M/dd/yy'
$c = 0
foreach($server in $servers) {
    "$c / $($servers.count)"
    $test = (test-connection $server -quiet -count 1)
    if($test) {
        $serverStatus = New-Object -type PSCustomObject -Property @{
            'serverName' = $server
            'serverStatus' = 'Online'
        }
    } else {
        $serverStatus = New-Object -type PSCustomObject -Property @{
            'serverName' = $server
            'serverStatus' = 'Offline'
        }
        $failCheck = 1
    }
    $statusObject += $serverStatus
    $c++
}

$statusObject | ConvertTo-Json | out-file status.json

if($failCheck -eq 0) {
    $panelTitle = "All Systems Operational"
} else {
    $panelTitle = "Not All Systems Operational"
}
$panelObject = @()
$panelObject +=  New-Object -type PSCustomObject -Property @{
    'panelTitle' = $panelTitle
    'lastCheck' = $lastCheck
}
"[" | out-file paneltext.json 
$panelObject | ConvertTo-Json | out-file paneltext.json -append
"]" | out-file paneltext.json -append
