import win32evtlog
import win32evtlogutil  # 이 부분을 추가해야 합니다
import xml.etree.ElementTree as ET


def save_logs_as_xml(log_type="Application", output_file="event_logs.xml"):
    server = "localhost"
    log_handle = win32evtlog.OpenEventLog(server, log_type)

    flags = win32evtlog.EVENTLOG_FORWARDS_READ | win32evtlog.EVENTLOG_SEQUENTIAL_READ
    events = win32evtlog.ReadEventLog(log_handle, flags, 0)

    # XML 루트 생성
    root = ET.Element("Events")

    for event in events:
        try:
            # 이벤트 메시지를 XML로 포맷
            event_xml = win32evtlogutil.SafeFormatMessage(event, log_type)
            event_element = ET.fromstring(event_xml)
            root.append(event_element)
        except Exception as e:
            print(f"Error processing event: {e}")

    # XML 파일로 저장
    tree = ET.ElementTree(root)
    tree.write(output_file, encoding="utf-8", xml_declaration=True)

    win32evtlog.CloseEventLog(log_handle)
    print(f"Logs saved to {output_file}")


# 실행
save_logs_as_xml(log_type="Application", output_file="event_logs.xml")
