
$cred = Get-Credential
connect-msolservice -credential $cred

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $Session


$domain = "domain.com"
$gam_path = '\\servername\c$\gam\gam.exe'
$ou_path = "CN=Users,DC=domain,dc=com"
$tag = "Created from Google"

$groups = (& $gam_path print groups) | ? { $_ -match "@$($domain)" } | % { $_.split('@')[0] }

foreach($group in $groups) {
    if(Get-ADGroup -filter {samAccountName -eq $group -and groupCategory -eq "Distribution"}) {
        #group exists
        #purge old members
        Get-ADGroupMember $group | % { Remove-ADGroupMember -identity $group -members $_.SamAccountName -Confirm:$false } 
        #get new member list from google, add them to group in AD
        $members = (& $gam_path print group-members group $group) | 
            ? { $_ -match 'ACTIVE'} | 
            % { $($_.split(",")[2]).split("@")[0] } |
            % { Add-ADGroupMember -Identity $group -members $_ }
    } else {
        #group does not exist
        #get info
        $group_info = & $gam_path info group $group
        $description = ($group_info | ? { $_ -match "Description:" }).split(":")[1]
        $display_name = ($group_info | ? { $_ -match "name:" }).split(":")[1]
        #create ad group
        New-ADGroup -Name $display_name.trim() -SamAccountName $group -GroupCategory Distribution -GroupScope Universal -DisplayName $display_name.trim() -Path $ou_path -Description $description.trim() -OtherAttributes @{Info=$tag}
        #add members from google
        $members = (& $gam_path print group-members group $group) | 
            ? { $_ -match 'ACTIVE'} | 
            % { $($_.split(",")[2]).split("@")[0] } |
            % { Add-ADGroupMember -Identity $group -members $_ }
    }
}