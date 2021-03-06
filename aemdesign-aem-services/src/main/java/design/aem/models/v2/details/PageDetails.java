package design.aem.models.v2.details;

import com.day.cq.i18n.I18n;
import com.day.cq.tagging.TagConstants;
import design.aem.components.ComponentProperties;
import design.aem.utils.components.ComponentsUtil;
import org.apache.commons.lang3.StringUtils;
import org.apache.sling.api.scripting.SlingScriptHelper;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

import static design.aem.utils.components.CommonUtil.*;
import static design.aem.utils.components.ComponentsUtil.*;
import static design.aem.utils.components.ConstantsUtil.*;
import static design.aem.utils.components.I18nUtil.getDefaultLabelIfEmpty;
import static design.aem.utils.components.TagUtil.getTagsAsAdmin;

public class PageDetails extends GenericDetails {
    protected static final Logger LOGGER = LoggerFactory.getLogger(PageDetails.class);

    private static final String COMPONENT_DETAILS_NAME = "page-details";

    private static final String DEFAULT_FORMAT_TITLE = "${title}";
    private static final String FIELD_FORMAT_TITLE = "titleFormat";
    private static final String FIELD_FORMATTED_TITLE = "titleFormatted";
    private static final String FIELD_FORMATTED_TITLE_TEXT = "titleFormattedText";
    private static final String FIELD_SUBCATEGORY = "subCategory";
    private static final String FIELD_CATEGORY = "category";

    @Override
    @SuppressWarnings("Duplicates")
    protected void ready() {
        com.day.cq.i18n.I18n i18n = new I18n(getRequest());

        final String DEFAULT_ARIA_ROLE = "banner";
        final String DEFAULT_TITLE_TAG_TYPE = "h1";
        final String DEFAULT_I18N_CATEGORY = "page-detail";
        final String DEFAULT_I18N_LABEL = "variantHiddenLabel";

        // default values for the component
        final String DEFAULT_TITLE = getPageTitle(getResourcePage(), getResource());
        final String DEFAULT_DESCRIPTION = getResourcePage().getDescription();
        final String DEFAULT_SUBTITLE = getResourcePage().getProperties().get(FIELD_PAGE_TITLE_SUBTITLE,"");
        final Boolean DEFAULT_HIDE_TITLE = false;
        final Boolean DEFAULT_HIDE_DESCRIPTION = false;
        final Boolean DEFAULT_SHOW_BREADCRUMB = true;
        final Boolean DEFAULT_SHOW_TOOLBAR = true;
        final Boolean DEFAULT_SHOW_PAGE_DATE = true;
        final Boolean DEFAULT_SHOW_PARSYS = true;

        setComponentFields(new Object[][]{
                {FIELD_VARIANT, DEFAULT_VARIANT},
                {"title", DEFAULT_TITLE},
                {FIELD_FORMAT_TITLE,""}, //tag path, will be resolved to value in processComponentFields
                {"description", DEFAULT_DESCRIPTION},
                {"hideDescription", DEFAULT_HIDE_DESCRIPTION},
                {"hideTitle", DEFAULT_HIDE_TITLE},
                {"showBreadcrumb", DEFAULT_SHOW_BREADCRUMB},
                {"showToolbar", DEFAULT_SHOW_TOOLBAR},
                {"showPageDate", DEFAULT_SHOW_PAGE_DATE},
                {"showParsys", DEFAULT_SHOW_PARSYS},
                {FIELD_LINK_TARGET, StringUtils.EMPTY, FIELD_TARGET},
                {FIELD_PAGE_URL, getPageUrl(getResourcePage())},
                {FIELD_PAGE_TITLE, DEFAULT_TITLE},
                {FIELD_PAGE_TITLE_NAV, getPageNavTitle(getResourcePage())},
                {FIELD_PAGE_TITLE_SUBTITLE, DEFAULT_SUBTITLE},
                {TagConstants.PN_TAGS, new String[]{}},
                {FIELD_SUBCATEGORY, new String[]{}},
                {FIELD_ARIA_ROLE,DEFAULT_ARIA_ROLE, FIELD_ARIA_DATA_ATTRIBUTE_ROLE},
                {FIELD_TITLE_TAG_TYPE, DEFAULT_TITLE_TAG_TYPE},
                {"variantHiddenLabel", getDefaultLabelIfEmpty("",DEFAULT_I18N_CATEGORY,DEFAULT_I18N_LABEL,DEFAULT_I18N_CATEGORY,i18n)},
        });

        componentProperties = ComponentsUtil.getComponentProperties(
                this,
                componentFields,
                DEFAULT_FIELDS_STYLE,
                DEFAULT_FIELDS_ACCESSIBILITY,
                DEFAULT_FIELDS_ANALYTICS,
                DEFAULT_FIELDS_DETAILS_OPTIONS);

        String[] tags = componentProperties.get(TagConstants.PN_TAGS, new String[]{});
        componentProperties.put(FIELD_CATEGORY,getTagsAsAdmin(getSlingScriptHelper(), tags, getRequest().getLocale()));

        String[] subCategory = componentProperties.get(FIELD_SUBCATEGORY, new String[]{});
        componentProperties.put(FIELD_SUBCATEGORY,getTagsAsAdmin(getSlingScriptHelper(), subCategory, getRequest().getLocale()));

        processCommonFields();

        //format fields
        componentProperties.putAll(processComponentFields(componentProperties,i18n,getSlingScriptHelper()), false);

    }

    /***
     * substitute formatted field template with fields from component.
     * @param componentProperties source map with fields
     * @param i18n i18n
     * @param sling sling helper
     * @return returns map with new values
     */
    @Override
    @SuppressWarnings("Duplicates")
    public Map<String, Object> processComponentFields(ComponentProperties componentProperties, com.day.cq.i18n.I18n i18n, SlingScriptHelper sling){
        Map<String, Object> newFields = new HashMap<>();

        try {

            String formattedTitle = compileComponentMessage(FIELD_FORMAT_TITLE, DEFAULT_FORMAT_TITLE, componentProperties, sling);
            Document fragment = Jsoup.parse(formattedTitle);
            String formattedTitleText = fragment.text();

            newFields.put(FIELD_FORMATTED_TITLE,
                    formattedTitle.trim()
            );
            newFields.put(FIELD_FORMATTED_TITLE_TEXT,
                    formattedTitleText.trim()
            );

        } catch (Exception ex) {
            LOGGER.error("Could not process component fields in {}", COMPONENT_DETAILS_NAME);
        }
        return newFields;
    }

}
