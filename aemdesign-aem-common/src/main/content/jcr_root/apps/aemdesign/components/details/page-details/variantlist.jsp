<%@ page import="org.apache.sling.commons.json.io.JSONWriter" %>
<%@ page import="org.apache.commons.lang3.ArrayUtils" %>
<%@ include file="/apps/aemdesign/global/global.jsp" %>
<%
    String componentPath = _component.getPath();
    Resource componentResource = _resourceResolver.resolve(componentPath);

    Iterable<Resource> componentResourceChildren = componentResource.getChildren();

    String SCRIPT_EXTENTION = ".jsp";
    String NAME_PREFIX = "variant.";

    final JSONWriter w = new JSONWriter(response.getWriter());
    w.setTidy(Arrays.asList(_slingRequest.getRequestPathInfo().getSelectors()).contains("tidy"));
    w.array();


    for (Resource nextChild : componentResourceChildren) {
        String childName = nextChild.getName();

        if (childName.startsWith(NAME_PREFIX) && childName.endsWith(SCRIPT_EXTENTION)) {

            String itemName = childName.replace(NAME_PREFIX,"").replace(SCRIPT_EXTENTION,"");
            String itemValue = itemName.replace("default","");
            String itemTitle =  StringUtils.capitalize(StringUtils.join(StringUtils.splitByCharacterTypeCamelCase(itemName)," "));

            w.object();
            w.key("text").value(itemTitle);
            w.key("name").value(itemName);
            w.key("description").value(itemTitle);
            w.key("value").value(itemValue);
            w.endObject();
        }
    }

    w.endArray();

%>