
$RemotePath = "http://xxxxxxxxxxxxxx"
$LocalPath = "c:\Downloads"
$maxDownloads = 3
$data = Invoke-WebRequest -Uri $RemotePath
foreach($filename in $data.links.href) {
    if($filename -match "csv|txt|pdf") {
        
        while((Get-BitsTransfer | where {$_.JobState -match 'Transferring|Connecting|TransientError'}).count -ge $maxDownloads ) {
            $percent = (($(((Get-BitsTransfer).BytesTransferred | Measure-Object -sum).sum)/$(((Get-BitsTransfer).BytesTotal | Measure-Object -sum).sum))*100)
            Write-Progress -Activity $RemotePath -status "$((((Get-BitsTransfer).BytesTransferred | Measure-Object -sum).sum)/1MB) / $((((Get-BitsTransfer).BytesTotal | Measure-Object -sum).sum)/1MB) " -PercentComplete $percent
        }
        if( (ls $LocalPath).Name -notcontains $filename ) {            
            Start-BitsTransfer -source "$RemotePath$filename" -destination $LocalPath -TransferType Download -Asynchronous
        }  
    }
    Get-BitsTransfer | where {$_.JobState -eq 'Transferred'} | Complete-BitsTransfer      
}

while ((Get-BitsTransfer | where {$_.JobState -match 'Transferring|Transferred|Connecting|TransientError'}).count -gt 0) {
    $percent = (($(((Get-BitsTransfer).BytesTransferred | Measure-Object -sum).sum)/$(((Get-BitsTransfer).BytesTotal | Measure-Object -sum).sum))*100)
    Write-Progress -Activity $RemotePath -status "$((((Get-BitsTransfer).BytesTransferred | Measure-Object -sum).sum)/1MB) / $((((Get-BitsTransfer).BytesTotal | Measure-Object -sum).sum)/1MB) " -PercentComplete $percent
    Get-BitsTransfer | where {$_.JobState -eq 'Transferred'} | Complete-BitsTransfer
}