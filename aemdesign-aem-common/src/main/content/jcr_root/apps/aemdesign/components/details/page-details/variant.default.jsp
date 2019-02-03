<div ${componentProperties.componentAttributes}${extraAttr}>
    <div class="container">
        <%@include file="page-details.header.jsp" %>
        <header>
        <c:if test="${not componentProperties.hideTitle}">
            <${componentProperties.titleType}>${componentProperties.titleFormatted}</${componentProperties.titleType}>
        </c:if>
        <c:if test="${not componentProperties.hideDescription}">
            <div class="description">${componentProperties.description}</div>
        </c:if>
        </header>
        <%@include file="page-details.footer.jsp" %>
    </div>
</div>