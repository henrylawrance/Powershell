#playin with PS in OSX 
$object = [PSCustomObject] @{
    User = $env:USER + "@" + $(hostname)
    Version = "PS " + $PSVersionTable.PSVersion -join ''
    Date = Get-Date -Format 'MM/dd/yyyy - HH:mm:ss'
}
$object | 
    Get-Member | 
    Where-Object {$_.MemberType -eq 'NoteProperty'} | 
    Select-Object Definition | 
    Format-List