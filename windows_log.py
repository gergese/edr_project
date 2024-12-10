import win32evtlog


def save_windows_logs_to_txt(log_type, output_file):
    """
    Windows 이벤트 로그를 읽어서 텍스트 파일로 저장합니다.

    Args:
        log_type (str): 로그 종류 (예: 'Application', 'System', 'Security').
        output_file (str): 로그를 저장할 파일 경로.
    """
    try:
        # 이벤트 로그 핸들 열기
        log_handle = win32evtlog.OpenEventLog(None, log_type)
        print(f"Processing logs from: {log_type}")

        # 파일에 쓰기 시작
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(f"Logs from {log_type}:\n\n")
            flags = (
                win32evtlog.EVENTLOG_BACKWARDS_READ
                | win32evtlog.EVENTLOG_SEQUENTIAL_READ
            )

            while True:
                events = win32evtlog.ReadEventLog(log_handle, flags, 0)
                if not events:
                    break
                for event in events:
                    event_id = event.EventID & 0xFFFF  # 실제 Event ID 추출
                    f.write(f"Event ID: {event_id}\n")
                    f.write(f"Record Number: {event.RecordNumber}\n")
                    f.write(f"Source Name: {event.SourceName}\n")
                    f.write(f"Time Generated: {event.TimeGenerated}\n")
                    f.write(f"Time Written: {event.TimeWritten}\n")
                    f.write(f"Event Type: {event.EventType}\n")
                    f.write(f"Event Category: {event.EventCategory}\n")
                    f.write(f"Computer Name: {event.ComputerName}\n")

                    # SID 처리
                    if event.Sid is not None:
                        f.write(f"SID: {event.Sid}\n")
                    else:
                        f.write("SID: None\n")

                    # 메시지 (StringInserts)
                    if event.StringInserts:
                        f.write(f"Message Data: {event.StringInserts}\n")
                    else:
                        f.write("Message Data: None\n")

                    # 추가 데이터 (Data)
                    if event.Data:
                        f.write(f"Additional Data: {event.Data}\n")
                    else:
                        f.write("Additional Data: None\n")

                    f.write("=" * 50 + "\n")

        print(f"Logs saved to {output_file}")

    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        win32evtlog.CloseEventLog(log_handle)


# 로그 종류와 파일 경로를 지정하여 실행
log_type = "Application"  # "System", "Security" 등을 사용할 수 있음
output_file = "application_logs.txt"

save_windows_logs_to_txt(log_type, output_file)
