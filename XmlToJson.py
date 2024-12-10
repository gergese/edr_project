import xml.etree.ElementTree as ET
import json


def wrap_with_root(xml_file):
    """
    XML 데이터를 단일 루트로 묶는 함수
    """
    with open(xml_file, "r", encoding="utf-8") as f:
        content = f.read().strip()

    # 단일 루트 요소 추가
    wrapped_content = f"<root>{content}</root>"
    return wrapped_content


def convert_xml_to_json(xml_file, json_file):
    try:
        # 루트로 묶인 XML 데이터를 읽기
        wrapped_xml = wrap_with_root(xml_file)

        # XML 파싱
        root = ET.fromstring(wrapped_xml)

        # XML을 딕셔너리로 변환
        def xml_to_dict(element):
            node = {}
            for child in element:
                if child.tag not in node:
                    node[child.tag] = xml_to_dict(child)
                else:
                    if not isinstance(node[child.tag], list):
                        node[child.tag] = [node[child.tag]]
                    node[child.tag].append(xml_to_dict(child))
            if element.text and element.text.strip():
                node["#text"] = element.text.strip()
            if element.attrib:
                node["@attributes"] = element.attrib
            return node

        data_dict = {root.tag: xml_to_dict(root)}

        # 딕셔너리를 JSON으로 저장
        with open(json_file, "w", encoding="utf-8") as json_f:
            json.dump(data_dict["root"], json_f, indent=4, ensure_ascii=False)

        print(f"변환 성공: {json_file}")
    except Exception as e:
        print(f"오류 발생: {e}")


# XML 파일 경로와 JSON 파일 경로 지정
xml_file = "event_logs.xml"
json_file = "output.json"

# 변환 함수 호출
convert_xml_to_json(xml_file, json_file)
