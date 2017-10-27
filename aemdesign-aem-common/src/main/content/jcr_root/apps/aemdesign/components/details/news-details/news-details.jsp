<%@ page import="com.day.cq.tagging.TagConstants" %>
<%@ page import="com.google.common.base.Throwables" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.apache.commons.lang3.BooleanUtils" %>
<%@ include file="/apps/aemdesign/global/global.jsp" %>
<%@ include file="/apps/aemdesign/global/components.jsp" %>
<%@ include file="/apps/aemdesign/global/images.jsp" %>
<%@ include file="/apps/aemdesign/global/component-details.jsp" %>
<%@ include file="/apps/aemdesign/global/i18n.jsp" %>
<%

    final Boolean DEFAULT_SHOW_BREADCRUMB = true;
    final Boolean DEFAULT_SHOW_TOOLBAR = false;
    final String DEFAULT_I18N_CATEGORY = "news-detail";
    final String DEFAULT_I18N_LABEL = "variantHiddenLabel";

    Object[][] componentFields = {
            {"title", _pageProperties.get(JcrConstants.JCR_TITLE, StringUtils.EMPTY)},
            {"description", _pageProperties.get(JcrConstants.JCR_DESCRIPTION, StringUtils.EMPTY)},
            {"showBreadcrumb", DEFAULT_SHOW_BREADCRUMB},
            {"showToolbar", DEFAULT_SHOW_TOOLBAR},
            {"author", ""},
            {TagConstants.PN_TAGS, new String[]{}},
            {FIELD_VARIANT, DEFAULT_VARIANT},
            {"variantHiddenLabel", getDefaultLabelIfEmpty("",DEFAULT_I18N_CATEGORY,DEFAULT_I18N_LABEL,DEFAULT_I18N_CATEGORY,_i18n)},
            {DETAILS_LINK_TEXT, getPageNavTitle(_currentPage)},
            {DETAILS_LINK_TITLE, getPageTitle(_currentPage)},
    };

    ComponentProperties componentProperties = getComponentProperties(
            pageContext,
            componentFields,
            DEFAULT_FIELDS_STYLE,
            DEFAULT_FIELDS_ACCESSIBILITY,
            DEFAULT_FIELDS_DETAILS_OPTIONS);

    Calendar publishDate = _properties.get("publishDate",_pageProperties.get(JcrConstants.JCR_CREATED, Calendar.getInstance()));

    componentProperties.put("publishDate",publishDate);

    //get format strings from dictionary
    String dateFormatString = _i18n.get("publishDateFormat",DEFAULT_I18N_CATEGORY);
    String dateDisplayFormatString = _i18n.get("publishDateDisplayFormat",DEFAULT_I18N_CATEGORY);

    //format date into formatted date
    SimpleDateFormat dateFormat = new SimpleDateFormat(dateFormatString);
    String publishDateText = dateFormat.format(publishDate.getTime());

    //format date into display date
    dateFormat = new SimpleDateFormat(dateDisplayFormatString);
    String publishDisplayDateText = dateFormat.format(publishDate.getTime());

    componentProperties.put("publishDateText",publishDateText);
    componentProperties.put("publishDisplayDateText",publishDisplayDateText);

    //get full published date display text
    String newsDateStatusText = _i18n.get("newsDateStatusText", DEFAULT_I18N_CATEGORY, publishDateText, publishDisplayDateText);
    componentProperties.put("newsDateStatusText",newsDateStatusText);

    String[] tags = componentProperties.get(TagConstants.PN_TAGS, new String[]{});

    componentProperties.put("tags",getTagsAsAdmin(_sling, tags, _slingRequest.getLocale()));

    componentProperties.putAll(getAssetInfo(_resourceResolver,
            getPageImgReferencePath(_currentPage),
            FIELD_PAGE_IMAGE));

    componentProperties.putAll(getAssetInfo(_resourceResolver,
            getResourceImagePath(_resource,DEFAULT_SECONDARY_IMAGE_NODE_NAME),
            FIELD_PAGE_IMAGE_SECONDARY));

    componentProperties.putAll(getAssetInfo(_resourceResolver,
            getResourceImagePath(_resource,DEFAULT_BACKGROUND_IMAGE_NODE_NAME),
            FIELD_PAGE_IMAGE_BACKGROUND));

    componentProperties.put(FIELD_REDIRECT_TARGET,_pageProperties.get(FIELD_REDIRECT_TARGET,""));


    componentProperties.put(FIELD_PAGE_IMAGE_THUMBNAIL,
            getBestFitRendition(
                    componentProperties.get(FIELD_PAGE_IMAGE, DEFAULT_IMAGE_BLANK),
                    componentProperties.get(DETAILS_THUMBNAIL_WIDTH, DEFAULT_THUMB_WIDTH_SM),
                    _resourceResolver
            )
    );

    componentProperties.put(FIELD_PAGE_IMAGE_SECONDARY_THUMBNAIL,
            getBestFitRendition(
                    componentProperties.get(FIELD_PAGE_IMAGE_SECONDARY, DEFAULT_IMAGE_BLANK),
                    componentProperties.get(DETAILS_THUMBNAIL_WIDTH, DEFAULT_THUMB_WIDTH_SM),
                    _resourceResolver
            )
    );

    componentProperties.putAll(processBadgeRequestConfig(componentProperties,_resourceResolver, request), true);

%>

<c:set var="componentProperties" value="<%= componentProperties %>"/>

<%@ include file="badgeconfig.jsp" %>

<c:choose>
    <c:when test="${COMPONENT_BADGE eq 'badge.card'}">
        <%@ include file="badge.card.jsp" %>
    </c:when>

    <c:when test="${COMPONENT_BADGE eq 'badge.cardAction'}">
        <%@ include file="badge.cardAction.jsp" %>
    </c:when>

    <c:when test="${COMPONENT_BADGE eq 'badge.cardSelect'}">
        <%@ include file="badge.cardSelect.jsp" %>
    </c:when>

    <c:when test="${COMPONENT_BADGE eq 'badge.cardIcon'}">
        <%@ include file="badge.cardIcon.jsp" %>
    </c:when>

    <c:when test="${COMPONENT_BADGE eq 'badge.cardIconAction'}">
        <%@ include file="badge.cardIconAction.jsp" %>
    </c:when>

    <c:when test="${COMPONENT_BADGE eq 'badge.cardIconSelect'}">
        <%@ include file="badge.cardIconSelect.jsp" %>
    </c:when>

    <c:when test="${COMPONENT_BADGE eq 'badge.cardHorizontal'}">
        <%@ include file="badge.cardHorizontal.jsp" %>
    </c:when>

    <c:when test="${COMPONENT_BADGE eq 'badge.icon'}">
        <%@ include file="badge.icon.jsp" %>
    </c:when>

    <c:when test="${COMPONENT_BADGE eq 'badge.image'}">
        <%@ include file="badge.image.jsp" %>
    </c:when>

    <c:when test="${COMPONENT_BADGE eq 'badge' or COMPONENT_BADGE eq 'badge.default'}">
        <%@ include file="badge.default.jsp" %>
    </c:when>

    <c:when test="${componentProperties.variant eq DEFAULT_VARIANT_HIDDEN}">
        <%@include file="variant.hidden.jsp" %>
    </c:when>

    <c:otherwise>
        <%@include file="variant.default.jsp" %>
    </c:otherwise>
</c:choose>

<%@include file="/apps/aemdesign/global/component-badge.jsp" %>
