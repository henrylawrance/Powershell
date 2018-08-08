
function Connect-MSOnline {
    <#
.SYNOPSIS
    Pulls stored credentials to connect to MSOnline
#>
    $credpath = "c:\cred.txt"
    if (!$(Get-PSSession | Where-Object { $_.ComputerName -eq "ps.outlook.com" })) {
        if (!(Test-Path $credpath)) { read-host -AsSecureString | ConvertFrom-SecureString | out-file $credpath }

        $pswd = Get-Content $credpath | ConvertTo-SecureString
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$env:USERNAME@$Default_Domain", $pswd
        connect-msolservice -credential $cred

        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -Authentication Basic -AllowRedirection
        Import-Module (Import-PSSession $Session -AllowClobber) -Global

    }
}

Export-ModuleMember -Function *