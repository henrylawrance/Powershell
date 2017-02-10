function changeOwner {
    [CmdletBinding()]
    param (
        $username
        ,$path
    )

    $domain=”DOMAIN”
    $ID = new-object System.Security.Principal.NTAccount($domain, $username)

    $acl = get-acl $path
    $acl.SetOwner($ID)
    set-acl -path $path -aclObject $acl
}




$users = get-aduser -filter {*} -SearchBase "OU=Faculty-Staff,dc=otterbein,dc=edu" -Properties HomeDirectory
foreach($user in $users) {
    if($user.HomeDirectory) {
        $files = $(ls $user.HomeDirectory -Recurse).FullName
        foreach($file in $files) {
            if(!($file | select-string -AllMatches '[\]\[]')) #skip files with special characters that break get-acl
            {
                $acl = get-acl "$file" -ErrorAction SilentlyContinue
                if($acl.Owner -match $user.SamAccountName) {
                    #"$file needs no change"
                } else {
                    if($acl) {
                        "$file needs update"
                        changeOwner $user.SamAccountName $file
                    }
                }
            }
        }
    }
}