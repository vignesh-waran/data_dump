$FilePath = "C:\Power Shell\cmdb_applications_view.csv"
$FileVersion = "C:\Power Shell\cmdb_application_installations_view.csv"
$UniversalSerialNumber = 'SAMDataDumpDeviceSerial'
$UniversalDeviceName = 'SAMDataDumpDeviceName'
$Uri = 'https://test-2-freshlink.freshgenie.com/itil/probes/add_config_items.json'
$RegistrationKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwb3J0YWxfdXJsIjoiaHR0cHM6Ly90ZXN0LTItZnJlc2hsaW5rLmZyZXNoZ2VuaWUuY29tIn0.my8GVA3kCEf3_riQwGJb40Ko7uBMosVxBnvOc-FqkcQ'
$AccessKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTAwMDAwMDM3MH0.FteRmDkBSvp2YVmLCSM8Vv1KcMTXbt6kNgpmV4uq-Dw'
$NumerOfDevices = 1000
$NUmberOfSoftwares = 200
$ProbeVersion = '3.3.0'


$Headers = @{
    ProbeVersion = $ProbeVersion;
    RegistrationKey = $RegistrationKey;
    AccessKey = $AccessKey;
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
    #$magic = Get-Random -Minimum 1 -Maximum $SoftwareListSize
    $sampleSoftware = ''
    $SerialNumber = $UniversalSerialNumber + $j.ToString()
    $DisplayName = $UniversalDeviceName + $j.ToString()
    For($i = 0;$i -lt $NUmberOfSoftwares-1;$i++)
    {
        $sampleSoftware += '{"softwareName": "'+$SoftwareNames[$i]+'", "softwareVersion":"'+$SoftwareVersion[$i]+'", "softwarePublisher":"-", "softwareLocation":"-", "softwareInstallDate":"-", "operatingSystem":"false"},'
    }
    $sampleSoftware += '{"softwareName": "'+$SoftwareNames[$NUmberOfSoftwares-1]+'", "softwareVersion":"'+$SoftwareVersion[$NUmberOfSoftwares-1]+'", "softwarePublisher":"-", "softwareLocation":"-", "softwareInstallDate":"-", "operatingSystem":"false"}'
    $Datum += '{"items":[{"Device":{"name":"'+$DisplayName+'", "type":"Laptop", "serial_number":"'+$SerialNumber+'", "uuid":"47FC1D01-522A-11CB-A0D1-C1066C96E0F6", "model":"ThinkPad L430", "manufacturer":"LENOVO", "ip_address":"127.0.0.1"}, "ComputerInfo":{"bios":"LENOVO - 2500", "total_physical_memory":"3.58595657348633", "total_virtual_memory":"7.17013549804688"}, "OperatingSystem":{"os":"Microsoft Windows 7 Professional ", "os_version":"6.1.7601", "os_service_pack":"1.0"}, "Components":{"processor":[{"model":"Intel(R) Core(TM) i5-3230M CPU @ 2.60GHz", "manufacturer":"GenuineIntel", "cpu_speed":"2.601", "no_of_cores":"2"}], "memory":[{"socket":"ChannelA-DIMM0", "capacity":"4", "speed":"1600 MHz", "memory_type":"RDRAM"}], "logical_drive":[{"drive_name":"C", "drive_type":"Local", "file_type":"NTFS", "capacity":"79", "free_space":"16"}, {"drive_name":"D", "drive_type":"Local", "file_type":"NTFS", "capacity":"216", "free_space":"189"}, {"drive_name":"F", "drive_type":"-", "file_type":"", "capacity":"", "free_space":""}], "network_adapter":[{"nic":"1x1 11b/g/n Wireless LAN PCI Express Half Mini Card Adapter", "ip_addr":"192.168.5.14", "mac_address":"2C:D0:5A:44:9D:31", "dhcp_enabled":"True"}, {"nic":"Realtek PCIe GBE Family Controller", "ip_addr":"192.168.1.201", "mac_address":"3C:97:0E:9A:EC:59", "dhcp_enabled":"True"}, {"nic":"VirtualBox Host-Only Ethernet Adapter", "ip_addr":"169.254.82.248", "mac_address":"08:00:27:00:78:16", "dhcp_enabled":"True"}]}, "Softwares":{"applications":['+ $sampleSoftware + ']}, "AuditInfo":{"last_scan_time":"1438599897958", "last_scan_status":"0", "last_successful_audit_time":"1438599897958"}}]}' 
}
$startDTM = (Get-Date)
For($i = 0;$i -lt $NumerOfDevices;$i++)
{
    
    
    $result = Invoke-RestMethod -Method Post -Uri $Uri -Headers $Headers -Body $Datum[$i] -ContentType 'application/json' -UserAgent 'FreshServiceProbe'
    Write-Host $result
    #$result = Invoke-WebRequest -Method Post -Uri $Uri -Headers $Headers -Body $data -ContentType 'application/json' -UserAgent 'FreshServiceProbe'
}
$endDTM = (Get-Date)
"Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds"
