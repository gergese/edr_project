Get-WinEvent -LogName Application | 
ForEach-Object {
    # 이벤트 XML 파싱
    $xml = [xml]$_.ToXml()
    $eventData = @{}
    $dataList = @()

    if ($xml.Event.EventData) {
        foreach ($data in $xml.Event.EventData.ChildNodes) {
            # Data 노드에 Name 속성이 존재하면 딕셔너리로 저장
            if ($data.Attributes["Name"]) {
                $eventData[$data.Attributes["Name"].Value] = $data.'#text'
            }
            # Name 속성이 없고 텍스트 값이 존재하면 리스트에 추가
            elseif ($data.'#text') {
                $dataList += $data.'#text'
            }
        }
    }

    # Name 속성이 없는 값이 존재하는 경우에만 Values 추가
    if ($dataList.Count -gt 0) {
        $eventData["Values"] = $dataList
    }

    # EventData가 비어있으면 $null로 설정
    if ($eventData.Count -eq 0) {
        $eventData = $null
    }

    # 이벤트 속성 추출
    $_ | Select-Object -Property @{
        Name = "EventId"; Expression = { $_.Id }
    }, @{
        Name = "Version"; Expression = { $_.Version }
    }, @{
        Name = "Qualifiers"; Expression = { $_.Qualifiers }
    }, @{
        Name = "Level"; Expression = { $_.Level }
    }, @{
        Name = "Task"; Expression = { $_.Task }
    }, @{
        Name = "Opcode"; Expression = { $_.Opcode }
    }, @{
        Name = "Keywords"; Expression = { $_.Keywords }
    }, @{
        Name = "RecordId"; Expression = { $_.RecordId }
    }, @{
        Name = "ProviderName"; Expression = { $_.ProviderName }
    }, @{
        Name = "ProviderId"; Expression = { $_.ProviderId.Guid }
    }, @{
        Name = "LogName"; Expression = { $_.LogName }
    }, @{
        Name = "ProcessId"; Expression = { $_.ProcessId }
    }, @{
        Name = "ThreadId"; Expression = { $_.ThreadId }
    }, @{
        Name = "MachineName"; Expression = { $_.MachineName }
    }, @{
        Name = "UserId"; Expression = { $_.UserId.Value }
    }, @{
        Name = "TimeCreated"; Expression = { $_.TimeCreated.DateTime }
    }, @{
        Name = "ActivityId"; Expression = { $_.ActivityId.Guid }
    }, @{
        Name = "EventData"; Expression = { $eventData }
    }
} | ConvertTo-Json -Depth 10 | Set-Content -Path "D:\script\edr_project\event_logs_filtered.json" -Encoding UTF8
