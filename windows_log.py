import win32evtlog
import json


def save_windows_logs_to_json(log_type, output_file):
    """
    Windows 이벤트 로그를 읽어서 JSON 파일로 저장합니다.

    Args:
        log_type (str): 로그 종류 (예: 'Application', 'System', 'Security').
        output_file (str): 로그를 저장할 파일 경로.
    """
    try:
        # 이벤트 로그 핸들 열기
        log_handle = win32evtlog.OpenEventLog(None, log_type)
        print(f"Processing logs from: {log_type}")

        logs = []  # 모든 로그를 저장할 리스트
        flags = (
            win32evtlog.EVENTLOG_BACKWARDS_READ | win32evtlog.EVENTLOG_SEQUENTIAL_READ
        )

        while True:
            events = win32evtlog.ReadEventLog(log_handle, flags, 0)
            if not events:
                break

            for event in events:
                # 각 이벤트를 딕셔너리로 변환
                log_entry = {
                    "EventID": event.EventID & 0xFFFF,  # 실제 Event ID 추출
                    "RecordNumber": event.RecordNumber,
                    "SourceName": event.SourceName,
                    "TimeGenerated": event.TimeGenerated.strftime("%Y-%m-%d %H:%M:%S"),
                    "TimeWritten": event.TimeWritten.strftime("%Y-%m-%d %H:%M:%S"),
                    "EventType": event.EventType,
                    "EventCategory": event.EventCategory,
                    "ComputerName": event.ComputerName,
                    "SID": str(event.Sid) if event.Sid else None,
                    "MessageData": event.StringInserts if event.StringInserts else None,
                    "AdditionalData": (
                        event.Data.decode("utf-8", errors="ignore")
                        if event.Data
                        else None
                    ),
                }

                logs.append(log_entry)  # 로그 리스트에 추가

        # JSON 파일로 저장
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(logs, f, indent=4, ensure_ascii=False)

        print(f"Logs saved to {output_file}")

    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        win32evtlog.CloseEventLog(log_handle)


# 로그 종류와 파일 경로를 지정하여 실행
log_type = "Application"  # "System", "Security" 등을 사용할 수 있음
output_file = "application_logs.json"

save_windows_logs_to_json(log_type, output_file)
