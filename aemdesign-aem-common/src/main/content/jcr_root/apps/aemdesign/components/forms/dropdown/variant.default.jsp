
<c:if test="${fn:length(componentProperties.displayValues) > 0}">
    <label class="${componentProperties.inputCss}" for="${componentProperties.id}"  ${fn:length(componentProperties.singleFieldErrorMessages) > 0 ? " class=\"failure\"" : ""}>
        <c:if test="${componentProperties.hideTitle == false}" >
            <span>${componentProperties.title}</span>
        </c:if><mark role="log">${fn:join(componentProperties.singleFieldErrorMessages, ',')}</mark>
        <select id="${componentProperties.id}"
                name="${componentProperties.name}"
                <c:if test="${componentProperties.multiSelect}" >
                    multiple="multiple"
                </c:if>>
            <c:forEach var="val" varStatus="status" items="${componentProperties.displayValues}">
                <c:set var="currentId" value="${componentProperties.id }'-'${status.index}" />
                <option value="${val.key}"
                        <c:if test="${fn:contains(componentProperties.values, val.key)}" >
                            selected="selected"
                        </c:if>>
                        ${val.value}
                </option>
            </c:forEach>
        </select>

    </label>
</c:if>