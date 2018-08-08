$global:Default_Domain = "domain.com"

Import-Module .\functions.psm1
Connect-MSOnline

$licensetype = get-content .\config_licensetype.json | ConvertFrom-Json


$Managed_OUs = @('Students') #, 'Alumni', 'Faculty-Staff', 'Other')

$ADAccounts = @()
$Managed_OUs | ForEach-Object {
    $SearchBase = "ou=" + $_ + ",dc=" + $($Default_Domain.split(".")[0]) + ",dc=" + $($Default_Domain.split(".")[1])
    $ADAccounts += get-aduser -filter {Enabled -eq $True} -SearchBase $SearchBase -Properties DistinguishedName
}

ForEach ($user in $ADAccounts) {
    $upn = $(($user.Name) + "@" + $Default_Domain)
    #Verify Usage Location
    if ((Get-MsolUser -UserPrincipalName $upn | Select-Object UsageLocation) -ne 'US') {
        Set-MsolUser -UserPrincipalName $upn -UsageLocation US
    }
    #Get Currently Set Licenses
    $setlicense = (Get-MsolUser -UserPrincipalName $upn ).Licenses.AccountSkuId

    #Identify Licenses to be Removed
    $remLicense = $($licensetype | Where-Object { $_.type -eq $user.DistinguishedName.Split(",")[1].replace("OU=", "")}).absent | Where-Object { $setlicense -contains $_}
    #Remove them
    $remLicense | ForEach-Object {
        Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $_
    }
    
    #Identify Licenses to be Added
    $addLicense = $($licensetype | Where-Object { $_.type -eq $user.DistinguishedName.Split(",")[1].replace("OU=", "")}).requires | Where-Object { $setlicense -notcontains $_}
    #Add them
    $addLicense | ForEach-Object { 
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $_
    }
}