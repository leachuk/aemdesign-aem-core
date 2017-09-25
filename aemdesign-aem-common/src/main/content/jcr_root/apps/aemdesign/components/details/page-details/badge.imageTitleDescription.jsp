<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="com.day.cq.wcm.api.Page" %>
<%@ include file="/apps/aemdesign/global/global.jsp" %>
<%@ include file="/apps/aemdesign/global/images.jsp" %>
<%@ include file="/apps/aemdesign/global/components.jsp" %>
<%@ include file="./common.jsp" %>
<%


    final String DEFAULT_IMAGE_PATH = "/content/dam/aemdesign/admin/defaults/environment.gif";

    String componentPath = "./" + PATH_DEFAULT_CONTENT + "/page-details";

    //init
    Page thisPage = (Page) request.getAttribute("badgePage");

    String url = getPageUrl(thisPage);

    Object[][] componentFields = {
            {"title", getPageTitle(thisPage)},
            {"description", thisPage.getDescription()},
            {"cq:tags", new String[]{}},
            //subCategory is resolved for Event Detail's badge
            {"subCategory", ""},
            {DETAILS_FIELD_CARDSIZE, ""},
            {"titleFormat",""}
    };

    ComponentProperties componentProperties = getComponentProperties(
            pageContext,
            thisPage,
            componentPath,
            componentFields);

    String pageTitle = getPageTitle(thisPage);

    //componentProperties.put("title", pageTitle);
    componentProperties.put("url", url);

    componentProperties.put("imgAlt", _i18n.get("readMoreAboutText", "pagedetail") + pageTitle);

    String width = "220";

    if(componentProperties.get(DETAILS_FIELD_CARDSIZE,"").endsWith(MEDIUM_THUMBNAIL_SIZE)){
        componentProperties.put("isMediumThumbnail",true);
        width = "320";
    }else if(componentProperties.get(DETAILS_FIELD_CARDSIZE,"").endsWith(LARGE_THUMBNAIL_SIZE)){
        componentProperties.put("isLargeThumbnail",true);
        width = "460";
    }else{
        componentProperties.put("isSmallThumbnail",true);
    }

    componentProperties.putAll(this.getPageNamedImage(_sling, thisPage, width));

    componentProperties.put(DEFAULT_SECONDARY_IMAGE_NODE_NAME, getSecondaryImageReferencePath(thisPage, "article/par/page-details/secondaryImage"));

    componentProperties.putAll(processComponentFields(componentProperties,_i18n,_sling));
%>
<c:set var="componentProperties" value="<%= componentProperties %>"/>

        <c:if test="${componentProperties.isLargeThumbnail}">
           <section class="col-6 left">
             <div class="major module">
        </c:if>
        <c:if test="${componentProperties.isMediumThumbnail}">
            <section class="col-4 left">
                <div class="major module">
        </c:if>
        <c:if test="${componentProperties.isSmallThumbnail}">
            <section class="col-3 left">
                <div class="module">
        </c:if>
                <div class="thumbnail ${componentProperties.emptyImagePlaceHolder}">
                    <a href="${componentProperties.url}"
                       title="${componentProperties.imgAlt}">${componentProperties.title}</a>

                    <c:if test="${not empty componentProperties.imgUrl}">
                        <img alt="${componentProperties.imgAlt}" width="${componentProperties.profileWidth}" height="${componentProperties.profileHeight}"
                             src="${componentProperties.imgUrl}"
                             <c:if test="${not empty componentProperties.secondaryImage}">class="rollover" data-img-rollover="${componentProperties.secondaryImage}"</c:if>
                        />
                    </c:if>
                </div>

                <div class="body">
                    <c:if test="${componentProperties.isLargeThumbnail || componentProperties.isMediumThumbnail}">
                        <h2>
                            <a href="${componentProperties.url}"
                               title="${componentProperties.imgAlt}">${componentProperties.titleFormatted}</a>
                        </h2>
                    </c:if>
                    <c:if test="${componentProperties.isSmallThumbnail}">
                        <h3>
                            <a href="${componentProperties.url}"
                               title="${componentProperties.imgAlt}">${componentProperties.titleFormatted}</a>
                        </h3>
                     </c:if>

                    <p>${componentProperties.description}
                    </p>
                </div>
            </div>
        </section>
