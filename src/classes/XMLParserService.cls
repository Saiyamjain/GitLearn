public with sharing class XMLParserService {
    private String rootElementName;

    public String transformOrderPayload(String xmlContent) {
        String escapedXml = xmlContent.escapeXml().replace('\n', '\\\\n').replace('\r', '\\\\r').replace('\t', '\\\\t');
        xmlContent = deleteTagsFromXML(xmlContent, new List<String>{'DeliveryAddress'});
        String jsonContent = xmlToJson(xmlContent);
        jsonContent = '{"originalXml":"' + escapedXml + '", "order":' + jsonContent.substringAfter(':');
        String statusStringToAppend = '"Status__c": "' + OrderPayloadWrapper.orderStatusMap.get(getXmlRootTagName(xmlContent).getName()) + '", ';
        if (String.isNotBlank(statusStringToAppend)) {
            jsonContent = jsonContent.substring(0, jsonContent.indexOf('"OrderID":'))
                    + statusStringToAppend
                    + jsonContent.substring(jsonContent.indexOf('"OrderID":'), jsonContent.length());
        }

        if (jsonContent.containsIgnoreCase('"Parts"')) {
            if (jsonContent.containsIgnoreCase('"Part"')) {
                String part = jsonContent.substringBetween('"Parts": {', '}') + '}';
                String modifiedPart = part.replace('"Part": ', '[') + ']';
                jsonContent = jsonContent.replace(part, modifiedPart).replace('"Parts": {', '"Parts": ').replace('},],', '],');
                jsonContent = jsonContent.substringBeforeLast('}').substringBeforeLast('}');
                jsonContent = jsonContent.replace(', "Parts":', '}, "orderItems": ');
            } else {
                jsonContent = jsonContent.replace(', "Parts":', '}, "orderItems": ');
                jsonContent = jsonContent.substringBeforeLast('}');
            }
        }

        return replaceFieldNames(jsonContent);
    }

    private String xmlToJson(String xml) {
        Dom.XmlNode root = getXmlRootTagName(xml);
        String jsonContent = parse(root, false);
        return jsonContent;
    }

    private String parse(Dom.XmlNode node, Boolean isChild) {
        String json = '';
        Boolean isArray = false;
        if (rootElementName == null) {
            rootElementName = node.getName();
        }
        if (node.getNodeType() == Dom.XmlNodeType.ELEMENT) {
            Map<String, List<String>> mapChildrenJSON = new Map<String, List<String>>();
            List<String> lstJSONForChildren = new List<String>();
            List<Dom.XmlNode> children = node.getChildElements();
            if (children.size() > 0) {
                for (Dom.XmlNode child : children) {
                    String tmp = parse(child, true);
                    if (tmp != '') {
                        if (!mapChildrenJSON.containsKey(child.getName())) {
                            mapChildrenJSON.put(child.getName(), new List<String>());
                        }
                        mapChildrenJSON.get(child.getName()).add(tmp);
                    }
                }
                for (String key : mapChildrenJSON.keySet()) {
                    if (mapChildrenJSON.get(key).size() > 1) {
                        if (isChild) {
                            lstJSONForChildren.add('[' + String.join(mapChildrenJSON.get(key), ', ') + ']');
                        } else {
                            lstJSONForChildren.add('"' + key + '": [' + String.join(mapChildrenJSON.get(key), ', ') + ']');
                        }
                        isArray = true;
                    } else {
                        lstJSONForChildren.add('"' + key + '": ' + mapChildrenJSON.get(key)[0]);
                    }
                }
            }

            List<String> lstAttributes = new List<String>(lstJSONForChildren);
            for (Integer i = 0; i < node.getAttributeCount(); i++) {
                String key = node.getAttributeKeyAt(i);
                String value = node.getAttribute(key, '');
                lstAttributes.add('"' + key + '": "' + value + '"');
            }

            String textContent = node.getText();
            if (textContent != null && textContent.trim() != '') {
                textContent = textContent.replace('"', '\\"');
                lstAttributes.add('"ele_text": "' + textContent + '"');
            }
            if (!isChild) {
                if (!isArray) {
                    json = '"' + node.getName() + '": {' + String.join(lstAttributes, ', ') + '}';
                } else {
                    json = ' {' + String.join(lstAttributes, ', ') + '}';
                }
            } else {
                if (lstAttributes.size() == 1 && textContent != null && textContent.trim() != '') {
                    json = '"' + textContent + '"';
                } else {
                    if (!isArray) {
                        if (lstAttributes.size() > 0) {
                            json = '{' + String.join(lstAttributes, ', ') + '}';
                        }
                    } else {
                        json = String.join(lstAttributes, ', ');
                    }
                }
            }
        }
        if (rootElementName == node.getName()) {
            if (!isArray) {
                json = '{' + json + '}';
            } else {
                json = '{"' + node.getName() + '" : ' + json + '}';
            }
        }
        return json;
    }

    private String deleteTagsFromXML(String xmlPayload, List<String> tagsToDelete) {
        for (String tag : tagsToDelete) {
            if (xmlPayload.contains('<' + tag + '>')) {
                xmlPayload = xmlPayload.remove('<' + tag + '>').remove('</' + tag + '>');
            }
        }
        return xmlPayload;
    }

    private String replaceFieldNames(String json) {
        for (String fieldName : OrderPayloadWrapper.orderPayloadFields.keySet()) {
            if (json.containsIgnoreCase(fieldName)) {
                json = json.replace('"' + fieldName + '":', '"' + OrderPayloadWrapper.orderPayloadFields.get(fieldName) + '":');
            }
        }
        return json;
    }

    private Dom.XmlNode getXmlRootTagName(String xml) {
        Dom.Document doc = new Dom.Document();
        doc.load(xml);
        return doc.getRootElement();
    }

    public static XMLParserService newInstance() {
        return (XMLParserService) Application.Service.newInstance(XMLParserService.class);
    }
}