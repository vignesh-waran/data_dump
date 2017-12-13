$FilePath = "C:\Power Shell\cmdb_applications_view.csv"
$FileVersion = "C:\Power Shell\cmdb_application_installations_view.csv"
$UniversalSerialNumber = 'SAMScanAgentDeviceSerial'
$UniversalDeviceName = 'SAMScanAgentDeviceName'
$Uri = 'https://test-3-freshlink.freshgenie.com/itil/scan_agents/register.json'
$Url = 'https://test-3-freshlink.freshgenie.com/itil/scan_agents/add_device.json'
$RegistrationKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwb3J0YWxfdXJsIjoiaHR0cHM6Ly90ZXN0LTMtZnJlc2hsaW5rLmZyZXNoZ2VuaWUuY29tIn0.-9gB-wgahgGf52xvN_1Uffwk9NqkwqNZcqtZanoN40o'
$NumerOfDevices = 2
$AccessKey = @()
$NUmberOfSoftwares = 200

$Headers = @{
    RegistrationKey = $RegistrationKey;
}
$Data = @()
For($k = 0;$k -lt $NumerOfDevices;$k++)
{
    $SerialNumber = $UniversalSerialNumber + $k.ToString()
    $Data += '{"serial_number":"'+$SerialNumber+'","version":"3.1.0","type":"mac"}'
}

For($l = 0;$l -lt $NumerOfDevices;$l++)
{
    $result = Invoke-WebRequest -Method Post -Uri $Uri -Headers $Headers -Body $Data[$l] -ContentType 'application/json' -UserAgent 'FreshServiceAgent'
    $AccessKey += $result.Headers['AccessKey']
    "response header: "+$result.Headers['AccessKey']
    Write-Host $result | ConvertTo-Json -Depth 10
    #$result = Invoke-WebRequest -Method Post -Uri $Uri -Headers $Headers -Body $data -ContentType 'application/json' -UserAgent 'FreshServiceProbe'
}
Write-Host $AccessKey
$HeadersAll = @()
For($m = 0;$m -lt $NumerOfDevices;$m++)
{
    $HeadersAll += @{
        RegistrationKey = $RegistrationKey;
        AccessKey = $AccessKey[$m];
    }
}

$SoftwareNames = @()
Import-Csv $FilePath |`
    ForEach-Object {
        $SoftwareNames += $_.'name'
    }

$softwareVersion = @()
Import-Csv $FileVersion |`
    ForEach-Object {
        $softwareVersion += $_.'application_version'
    }


$Datum = @()
$SoftwareListSize = $SoftwareNames.Length
Write-Host $SoftwareListSize
$VersionListSize = $softwareVersion.Length
Write-Host $VersionListSize

For($j = 0;$j -lt $NumerOfDevices;$j++)
{
    $magic = Get-Random -Minimum 1 -Maximum $SoftwareListSize
    $sampleSoftware = ''
    $SerialNumber = $UniversalSerialNumber + $j.ToString()
    $DisplayName = $UniversalDeviceName + $j.ToString()
    For($i = 0;$i -lt $NUmberOfSoftwares-1;$i++)
    {
        $sampleSoftware += '{"softwareName": "'+$SoftwareNames[($magic+$i)%$SoftwareListSize]+'", "softwareVersion":"'+$SoftwareVersion[($magic+$i)%$VersionListSize]+'", "softwarePublisher":"-", "softwareLocation":"-", "softwareInstallDate":"-", "operatingSystem":"false"},'
    }
    $sampleSoftware += '{"softwareName": "'+$SoftwareNames[($magic+$NUmberOfSoftwares-1)%$SoftwareListSize]+'", "softwareVersion":"'+$SoftwareVersion[($magic+$NUmberOfSoftwares-1)%$SoftwareListSize]+'", "softwarePublisher":"-", "softwareLocation":"-", "softwareInstallDate":"-", "operatingSystem":"false"}'
    $Datum += '{"items":[{"Device":{"name":"'+$DisplayName+'", "type":"Laptop", "serial_number":"'+$SerialNumber+'", "uuid":"47FC1D01-522A-11CB-A0D1-C1066C96E0F6", "model":"ThinkPad L430", "manufacturer":"LENOVO", "ip_address":"127.0.0.1"}, "ComputerInfo":{"bios":"LENOVO - 2500", "total_physical_memory":"3.58595657348633", "total_virtual_memory":"7.17013549804688"}, "OperatingSystem":{"os":"Microsoft Windows 7 Professional ", "os_version":"6.1.7601", "os_service_pack":"1.0"}, "Components":{"processor":[{"model":"Intel(R) Core(TM) i5-3230M CPU @ 2.60GHz", "manufacturer":"GenuineIntel", "cpu_speed":"2.601", "no_of_cores":"2"}], "memory":[{"socket":"ChannelA-DIMM0", "capacity":"4", "speed":"1600 MHz", "memory_type":"RDRAM"}], "logical_drive":[{"drive_name":"C", "drive_type":"Local", "file_type":"NTFS", "capacity":"79", "free_space":"16"}, {"drive_name":"D", "drive_type":"Local", "file_type":"NTFS", "capacity":"216", "free_space":"189"}, {"drive_name":"F", "drive_type":"-", "file_type":"", "capacity":"", "free_space":""}], "network_adapter":[{"nic":"1x1 11b/g/n Wireless LAN PCI Express Half Mini Card Adapter", "ip_addr":"192.168.5.14", "mac_address":"2C:D0:5A:44:9D:31", "dhcp_enabled":"True"}, {"nic":"Realtek PCIe GBE Family Controller", "ip_addr":"192.168.1.201", "mac_address":"3C:97:0E:9A:EC:59", "dhcp_enabled":"True"}, {"nic":"VirtualBox Host-Only Ethernet Adapter", "ip_addr":"169.254.82.248", "mac_address":"08:00:27:00:78:16", "dhcp_enabled":"True"}]}, "Softwares":{"applications":['+ $sampleSoftware + ']}, "AuditInfo":{"last_scan_time":"1438599897958", "last_scan_status":"0", "last_successful_audit_time":"1438599897958"}}]}' 
}
$startDTM = (Get-Date)
For($p = 0;$p -lt $NumerOfDevices;$p++)
{
    $output = Invoke-RestMethod -Method Post -Uri $Url -Headers $HeadersAll[$p]  -Body $Datum[$p] -ContentType 'application/json' -UserAgent 'FreshServiceProbe'
    Write-Host $output
    #$result = Invoke-WebRequest -Method Post -Uri $Uri -Headers $Headers -Body $data -ContentType 'application/json' -UserAgent 'FreshServiceProbe'
}
$endDTM = (Get-Date)
"Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds"