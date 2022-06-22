function Set-HoNReconnect {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Ip,

        [Parameter(Mandatory = $false)]
        [boolean] $x64 = $true
    )

    $documentsFolder = [Environment]::GetFolderPath("MyDocuments")
    $honFolder = $x64 ? "Heroes of Newerth x64" : "Heroes of Newerth"
    $reconnectFilePath = Join-Path $documentsFolder $honFolder "game" "reconnect.cfg" -Resolve

    $reconnectFileContent = Get-Content -Path $reconnectFilePath
    
    $reconnectFileObject = [Ordered]@{
        "cl_reconnectAttempts" = $reconnectFileContent[0].Split(" ")[1];
        "cl_reconnectTimestamp" = $reconnectFileContent[1].Split(" ")[1];
        "cl_connectionID" = (Get-Random -Minimum 100 -Maximum 999);
        "CheckReconnect" = "$Ip 4294967295"
    }

    $updatedReconnectFileContent = $reconnectFileObject.Keys | ForEach-Object { "$_ $($reconnectFileObject[$_])" }

    Set-Content -Path $reconnectFilePath -Value $updatedReconnectFileContent

    Write-Host "Updated ""$reconnectFilePath"" content to:"
    $updatedReconnectFileContent | Write-Host
}

function Get-HoNServerInfo {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Ip
    )

    try {
        $serverInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$Ip"
    } catch {
        Write-Error "Cannot get data about ""$Ip"" IP."
        return
    }
    
    $pingInfo = Test-Connection $serverInfo.query -Ping -Count 1
    $ping = $pingInfo.Status -Eq "TimedOut" ? "-" : $pingInfo.Latency

    [PSCustomObject][ordered]@{
        "Host"    = $Ip;
        "IP"      = $serverInfo.query;
        "Country" = $serverInfo.country;
        "Region"  = $serverInfo.regionName;
        "Ping"    = $ping;
    } | Format-Table
}