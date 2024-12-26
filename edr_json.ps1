param (
    [string[]]$LogName = @("Application"), # 기본값을 Application으로 설정
    [string]$ServerUrl = "http://192.168.64.131:5001", # 서버 URL (localhost:5001 포트)
    [int]$PollingInterval = 1 # 이벤트 로그 폴링 주기 (초 단위)
)

# 로그 이름마다 처리
foreach ($log in $LogName) {
    Write-Host "처리 중: $log" -ForegroundColor Cyan

    # 마지막으로 처리된 로그의 RecordId를 추적
    $lastRecordId = 0

    # 1. 기존 로그 처리: RecordId가 작은 로그부터 큰 로그까지 모두 가져오기
    try {
        $logs = Get-WinEvent -LogName $log # 첫 1000개의 로그 가져오기 (필요시 조정)
        if ($logs) {
            $logs | ForEach-Object {
                # 이벤트 XML 파싱
                $xml = [xml]$_.ToXml()
                $eventData = @{ }
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

                # 이벤트 속성 추출
                $logObject = $_ | Select-Object -Property @(
                    @{ Name = "EventId"; Expression = { $_.Id } },
                    @{ Name = "Version"; Expression = { $_.Version } },
                    @{ Name = "Qualifiers"; Expression = { $_.Qualifiers } },
                    @{ Name = "Level"; Expression = { $_.Level } },
                    @{ Name = "Task"; Expression = { $_.Task } },
                    @{ Name = "Opcode"; Expression = { $_.Opcode } },
                    @{ Name = "Keywords"; Expression = { $_.Keywords } },
                    @{ Name = "RecordId"; Expression = { $_.RecordId } },
                    @{ Name = "ProviderName"; Expression = { $_.ProviderName } },
                    @{ Name = "ProviderId"; Expression = { $_.ProviderId.Guid } },
                    @{ Name = "LogName"; Expression = { $_.LogName } },
                    @{ Name = "ProcessId"; Expression = { $_.ProcessId } },
                    @{ Name = "ThreadId"; Expression = { $_.ThreadId } },
                    @{ Name = "MachineName"; Expression = { $_.MachineName } },
                    @{ Name = "UserId"; Expression = { $_.UserId.Value } },
                    @{ Name = "TimeCreated"; Expression = { $_.TimeCreated.ToUniversalTime().ToString("o") } },
                    @{ Name = "ActivityId"; Expression = { $_.ActivityId.Guid } },
                    @{ Name = "EventData"; Expression = { $eventData } }
                )

                # 실시간으로 HTTP POST 전송
                try {
                    $response = Invoke-RestMethod -Uri $ServerUrl -Method Post -Body ($logObject | ConvertTo-Json -Depth 10) -ContentType "application/json"
                    Write-Host "로그 전송 성공: $($logObject.EventId)" -ForegroundColor Green
                } catch {
                    Write-Host "로그 전송 실패: $_" -ForegroundColor Red
                }

                # 마지막으로 처리된 RecordId 갱신
                $lastRecordId = $_.RecordId
            }
        }
    } catch {
        Write-Host "기존 로그 처리 중 오류가 발생했습니다: $_" -ForegroundColor Red
    }

    # 2. 실시간 로그 처리: 새로운 로그만 처리
    while ($true) {
        try {
            $logs = Get-WinEvent -LogName $log -MaxEvents 10
            if ($logs) {
                $logs | Where-Object { $_.RecordId -gt $lastRecordId } | ForEach-Object {
                    # 이벤트 XML 파싱
                    $xml = [xml]$_.ToXml()
                    $eventData = @{ }
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

                    # 이벤트 속성 추출
                    $logObject = $_ | Select-Object -Property @(
                        @{ Name = "EventId"; Expression = { $_.Id } },
                        @{ Name = "Version"; Expression = { $_.Version } },
                        @{ Name = "Qualifiers"; Expression = { $_.Qualifiers } },
                        @{ Name = "Level"; Expression = { $_.Level } },
                        @{ Name = "Task"; Expression = { $_.Task } },
                        @{ Name = "Opcode"; Expression = { $_.Opcode } },
                        @{ Name = "Keywords"; Expression = { $_.Keywords } },
                        @{ Name = "RecordId"; Expression = { $_.RecordId } },
                        @{ Name = "ProviderName"; Expression = { $_.ProviderName } },
                        @{ Name = "ProviderId"; Expression = { $_.ProviderId.Guid } },
                        @{ Name = "LogName"; Expression = { $_.LogName } },
                        @{ Name = "ProcessId"; Expression = { $_.ProcessId } },
                        @{ Name = "ThreadId"; Expression = { $_.ThreadId } },
                        @{ Name = "MachineName"; Expression = { $_.MachineName } },
                        @{ Name = "UserId"; Expression = { $_.UserId.Value } },
                        @{ Name = "TimeCreated"; Expression = { $_.TimeCreated.DateTime } },
                        @{ Name = "ActivityId"; Expression = { $_.ActivityId.Guid } },
                        @{ Name = "EventData"; Expression = { $eventData } }
                    )

                    # 실시간으로 HTTP POST 전송
                    try {
                        $response = Invoke-RestMethod -Uri $ServerUrl -Method Post -Body ($logObject | ConvertTo-Json -Depth 10) -ContentType "application/json"
                        Write-Host "로그 전송 성공: $($logObject.EventId)" -ForegroundColor Green
                    } catch {
                        Write-Host "로그 전송 실패: $_" -ForegroundColor Red
                    }

                    # 마지막으로 처리된 RecordId 갱신
                    $lastRecordId = $_.RecordId
                }
            }
        } catch {
            Write-Host "실시간 로그 처리 중 오류가 발생했습니다: $_" -ForegroundColor Red
        }

        # 폴링 간격 대기
        Start-Sleep -Seconds $PollingInterval
    }
}
