---
---

```powershell
function ConvertTo-MD5Hash {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]$Text,
        [switch]$Raw
    )

    $md5 = [System.Security.Cryptography.MD5CryptoServiceProvider]::New()
    $utf8 = [System.Text.UTF8Encoding]::New()
    $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($Text)))
    if (!$Raw.IsPresent) { $hash.ToLower() -replace '-','' }
    else { $hash }
}

$dcs = Get-ADDomainController -Filter {IsReadOnly -eq $false}
$providerName = 'Microsoft-Windows-Security-Auditing'
$filterXPath = 'Event[System[(EventID=4768) or (EventID=4769)]]'
$i = 0

do {
    $dcs | ForEach-Object {

        Write-Host "Querying DC: $($_.HostName)..."

        $splat = @{
            ProviderName = $providerName
            FilterXPath  = $filterXPath
            ComputerName = $_.HostName
            MaxEvents    = 1000
        }

        $events = Get-WinEvent @splat | ForEach-Object {
            $eventXml = [xml]$_.ToXml()
            $ticketEncryptionTypeRaw = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'TicketEncryptionType' }).'#text'

            $description = switch ($_.Id) {
                4768 { 'A Kerberos authentication ticket (TGT) was requested' }
                4769 { 'A Kerberos service ticket (TGS) was requested' }
            }

            $ticketEncryptionType = switch ($ticketEncryptionTypeRaw) {
                '0x1'        { 'DES-CBC-CRC' }
                '0x3'        { 'DES-CBC-MD5' }
                '0x11'       { 'AES128-CTS-HMAC-SHA1-96' }
                '0x12'       { 'AES256-CTS-HMAC-SHA1-96' }
                '0x17'       { 'RC4-HMAC' }
                '0x18'       { 'RC4-HMAC-EXP' }
                '0xFFFFFFFF' { 'Audit failure' }
            }

            [PSCustomObject]@{
                EventID                 = $_.Id
                Description             = $description
                # DC information
                TimeCreated             = $_.TimeCreated
                DomainController        = $_.MachineName
                DCMsDsSupEncTyp         = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'DCSupportedEncryptionTypes' }).'#text'
                DCAvailableKeys         = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'DCAvailableKeys' }).'#text'
                # Account information
                AccountName             = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetUserName' }).'#text'
                AccountMsDsSupEncTyp    = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'AccountSupportedEncryptionTypes' }).'#text'
                AccountAvailableKeys    = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'AccountAvailableKeys' }).'#text'
                # Service information
                ServiceName             = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'ServiceName' }).'#text'
                ServiceMsDsSupEncTyp    = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'ServiceSupportedEncryptionTypes' }).'#text'
                ServiceAvailableKeys    = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'ServiceAvailableKeys' }).'#text'
                TicketEncryptionTypeRaw = $ticketEncryptionTypeRaw
                TicketEncryptionType    = $ticketEncryptionType
                MD5Checksum             = ($eventXml.OuterXml | ConvertTo-MD5Hash)
            }
        }

        $events | Group-Object TicketEncryptionTypeRaw -NoElement | Sort-Object Count -D | Format-Table -AutoSize
        Write-Host "Found $(($events | Measure-Object).Count) events (max events: $($splat.MaxEvents))"
        $events | Export-Csv -Path "C:\temp\events_notAES256.csv" -Delimiter ';' -Append -Encoding UTF8 -NoTypeInformation
    }
    $i++
    Write-Host "End of loop #$i"

    # Deduplicate the output file every 5 loops
    if ($i % 5 -eq 0) {
        Write-Host "Deduplicating output file..."
        $csv = Import-Csv -Path "C:\temp\events_notAES256.csv" -Delimiter ';' -Encoding UTF8
        Write-Host "Items before deduplication: $(($csv | Measure-Object).Count)"
        $csv = $csv | Sort-Object MD5Checksum -Unique
        Write-Host "Items after deduplication: $(($csv | Measure-Object).Count)"
        $csv | Export-Csv -Path "C:\temp\events_notAES256.csv" -Delimiter ';' -Encoding UTF8 -NoTypeInformation -Force
    }

} while ($true)
```

```xml
<Event xmlns='http://schemas.microsoft.com/win/2004/08/events/event'>
    <System>
        <Provider Name='Microsoft-Windows-Security-Auditing'
            Guid='{54849625-5478-4994-a5ba-3e3b0328c30d}' />
        <EventID>4769</EventID>
        <Version>2</Version>
        <Level>0</Level>
        <Task>14337</Task>
        <Opcode>0</Opcode>
        <Keywords>0x8020000000000000</Keywords>
        <TimeCreated SystemTime='2026-01-28T13:19:22.1760027Z' />
        <EventRecordID>39886463312</EventRecordID>
        <Correlation />
        <Execution ProcessID='700' ThreadID='3528' />
        <Channel>Security</Channel>
        <Computer>DC01.corp.contoso.com</Computer>
        <Security />
    </System>
    <EventData>
        <Data Name='TargetUserName'>jsmith@corp.contoso.com</Data>
        <Data Name='TargetDomainName'>CORP.CONTOSO.COM</Data>
        <Data Name='ServiceName'>PC01$</Data>
        <Data Name='ServiceSid'>S-1-5-21-1636901212-417312000-1404974576-69734</Data>
        <Data Name='TicketOptions'>0x40810000</Data>
        <Data Name='TicketEncryptionType'>0x12</Data>
        <Data Name='IpAddress'>::ffff:10.0.0.10</Data>
        <Data Name='IpPort'>56370</Data>
        <Data Name='Status'>0x0</Data>
        <Data Name='LogonGuid'>{471190ae-606c-6413-06f9-6642b3757bcf}</Data>
        <Data Name='TransmittedServices'>-</Data>
        <Data Name='RequestTicketHash'>gSijBKy3zmnyqDaffKq9Hmi/oRQtVVyZnDIN+Wp8W9U=</Data>
        <Data Name='ResponseTicketHash'>7Ohim9a7VKIyZ4h74XZP3KMqcEERTYIbpSEDk1VETaY=</Data>
        <Data Name='AccountSupportedEncryptionTypes'>N/A</Data>
        <Data Name='AccountAvailableKeys'>N/A</Data>
        <Data Name='ServiceSupportedEncryptionTypes'>0x1C (RC4, AES128-SHA96, AES256-SHA96)</Data>
        <Data Name='ServiceAvailableKeys'>AES-SHA1, RC4</Data>
        <Data Name='DCSupportedEncryptionTypes'>0x1F (DES, RC4, AES128-SHA96, AES256-SHA96)</Data>
        <Data Name='DCAvailableKeys'>AES-SHA1, RC4</Data>
        <Data Name='ClientAdvertizedEncryptionTypes'>
            AES256-CTS-HMAC-SHA1-96
            AES128-CTS-HMAC-SHA1-96
            RC4-HMAC-NT
            RC4-HMAC-NT-EXP
            RC4-HMAC-OLD-EXP</Data>
        <Data Name='SessionKeyEncryptionType'>0x12</Data>
    </EventData>
</Event>
```