package design.aem.models.v2.details;

import com.day.cq.i18n.I18n;
import com.day.cq.tagging.Tag;
import com.day.cq.tagging.TagConstants;
import design.aem.components.ComponentProperties;
import design.aem.utils.components.ComponentsUtil;
import org.apache.jackrabbit.vault.util.JcrConstants;
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
import static design.aem.utils.components.TagUtil.getTagValueAsAdmin;
import static design.aem.utils.components.TagUtil.getTagsAsAdmin;
import static org.apache.commons.lang3.StringUtils.isEmpty;

public class ContactDetails extends GenericDetails {
    protected static final Logger LOGGER = LoggerFactory.getLogger(ContactDetails.class);

    static final String COMPONENT_DETAILS_NAME = "contact-details";

    static final String DEFAULT_FORMAT_TITLE = "${honorificPrefix} ${givenName} ${familyName}";
    static final String DEFAULT_FORMAT_DESCRIPTION = "${jobTitle}";
    static final String FIELD_FORMAT_TITLE = "titleFormat";
    static final String FIELD_FORMAT_DESCRIPTION = "descriptionFormat";
    static final String FIELD_FORMATTED_TITLE = "titleFormatted";
    static final String FIELD_FORMATTED_TITLE_TEXT = "titleFormattedText";
    static final String FIELD_FORMATTED_DESCRIPTION = "descriptionFormatted";
    static final String I18N_CATEGORY = "contact-detail";


    @Override
    @SuppressWarnings("Duplicates")
    protected void ready() {
        I18n i18n = new I18n(getRequest());

        final String DEFAULT_TITLE_TAG_TYPE = "div";
        final Boolean DEFAULT_HIDE_DESCRIPTION = false;
        final Boolean DEFAULT_SHOW_BREADCRUMB = true;
        final Boolean DEFAULT_SHOW_TOOLBAR = true;
        final String DEFAULT_I18N_CATEGORY = I18N_CATEGORY;
        final String DEFAULT_I18N_LABEL = "variantHiddenLabel";

        final String FIELD_HONOTIFIC_PREFIX = "honorificPrefix";
        final String FIELD_TITLE = "title";

        final String DEFAULT_TITLE = getPageTitle(getResourcePage(), getResource());

        /*
          Component Fields Helper

          Structure:
          1 required - property name,
          2 required - default value,
          3 optional - name of component attribute to add value into
          4 optional - canonical name of class for handling multivalues, String or Tag
         */
        setComponentFields(new Object[][]{
                {FIELD_VARIANT, DEFAULT_VARIANT},
                {FIELD_TITLE_TAG_TYPE, DEFAULT_TITLE_TAG_TYPE},
                {FIELD_TITLE, getResourcePage().getProperties().get(JcrConstants.JCR_TITLE, getResourcePage().getName())},
                {FIELD_FORMAT_TITLE,""},
                {FIELD_HONOTIFIC_PREFIX, ""}, //tag path
                {"givenName",""},
                {"familyName",""},
                {FIELD_FORMAT_TITLE, ""}, //tag path, will be resolved to value in processComponentFields
                {"jobTitle",""},
                {"employee",""},
                {"email",""},
                {"contactNumber",""},
                {FIELD_FORMAT_DESCRIPTION, ""}, //tag path, will be resolved to value in processComponentFields
                {"hideDescription", DEFAULT_HIDE_DESCRIPTION},
                {TagConstants.PN_TAGS, new String[]{},"data-tags", Tag.class.getCanonicalName()},
                {"showBreadcrumb", DEFAULT_SHOW_BREADCRUMB},
                {"showToolbar", DEFAULT_SHOW_TOOLBAR},
                {FIELD_PAGE_URL, getPageUrl(getResourcePage())},
                {FIELD_PAGE_TITLE, DEFAULT_TITLE},
                {FIELD_PAGE_TITLE_NAV, getPageNavTitle(getResourcePage())},
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

        componentProperties.put("category",getTagsAsAdmin(getSlingScriptHelper(), tags, getRequest().getLocale()));

        //grab value for prefix
        componentProperties.put(FIELD_HONOTIFIC_PREFIX,
                getTagValueAsAdmin(componentProperties.get(FIELD_HONOTIFIC_PREFIX, ""),getSlingScriptHelper())
        );

        //format fields
        componentProperties.putAll(processComponentFields(componentProperties,i18n,getSlingScriptHelper()), false);

        componentProperties.put(DETAILS_DESCRIPTION,componentProperties.get(FIELD_FORMATTED_DESCRIPTION,""));

        processCommonFields();

        //set something if title formatted is empty
        if (isEmpty(componentProperties.get(FIELD_FORMATTED_TITLE,""))) {
            componentProperties.put(FIELD_FORMATTED_TITLE,componentProperties.get(FIELD_TITLE,""));
            componentProperties.put(FIELD_FORMATTED_TITLE_TEXT,componentProperties.get(FIELD_TITLE,""));
        }
    }

    /***
     * substitute formatted field template with fields from component
     * @param componentProperties source map with fields
     * @param i18n i18n instance
     * @param sling sling instance
     * @return returns map with new values
     */
    @Override
    @SuppressWarnings("Duplicates")
    public Map<String, Object> processComponentFields(ComponentProperties componentProperties, com.day.cq.i18n.I18n i18n, SlingScriptHelper sling){
        Map<String, Object> newFields = new HashMap();

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
            newFields.put(FIELD_FORMATTED_DESCRIPTION,
                    compileComponentMessage(FIELD_FORMAT_DESCRIPTION, DEFAULT_FORMAT_DESCRIPTION, componentProperties, sling).trim()
            );

        } catch (Exception ex) {
            LOGGER.error("Could not process component fields in {}", COMPONENT_DETAILS_NAME);
        }
        return newFields;
    }
}
