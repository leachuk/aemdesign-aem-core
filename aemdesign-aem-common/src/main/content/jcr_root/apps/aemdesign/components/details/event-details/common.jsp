<%@ page import="java.text.SimpleDateFormat" %><%!

    // default values for the component
    final String DEFAULT_TITLE = "Event Title";
    final String DEFAULT_DESCRIPTION = "";
    final String DEFAULT_HIDE_SITE_TITLE = "false";
    final String DEFAULT_HIDE_SEPARATOR = "false";
    final String DEFAULT_HIDE_SUMMARY = "false";
    final String EVENT_DISPLAY_DATE_FORMAT = "EEE d MMMMM";
    final String EVENT_DISPLAY_DATE_FORMAT_ISO = "yyyy-MM-dd'T'HH:mm:ss'Z'";
    final String EVENT_TIME_DEFAULT_FORMAT = "h:mm a";
    final String HOURS_TIME_FORMAT = "h a";
    final String MINUTES_TIME_FORMAT = "mm";
    final String TIME_ZERO_FORMAT = "00";
    final Calendar DEFAULT_EVENT_START_DATE = Calendar.getInstance();
    final Calendar DEFAULT_EVENT_END_DATE = Calendar.getInstance();
    final String DEFAULT_EVENT_LOC = "";
    final String DEFAULT_EVENT_REF_LABEL = "";
    final String DEFAULT_EVENT_REF_LINK = "";
    final String DEFAULT_META_DATA_SEP = "";
    final Boolean DEFAULT_SHOW_BREADCRUMB = true;
    final Boolean DEFAULT_SHOW_TOOLBAR = true;
    final String DEFAULT_FORMAT_TITLE = "${title}";
    final String FIELD_FORMAT_TITLE = "titleFormat";
    final String FIELD_FORMATTED_TITLE = "titleFormatted";
    final String FIELD_FORMATTED_TITLE_TEXT = "titleFormattedText";
    final String DEFAULT_FORMAT_SUBTITLE = "${eventStartDateText} to ${eventEndDateText}";
    final String DEFAULT_FORMAT_DISPLAYDATE = "${eventStartDateText} to ${eventEndDateText}";
    final String DEFAULT_FORMAT_DISPLAYTIME = "${eventStartTimeText} to ${eventEndTimeText}";
    final String I18N_CATEGORY = "event-detail";

    final String I18N_READMORE = "readMoreAboutText";
    final String I18N_FILTERBYTEXT = "filterByText";
    final String SECONDARY_IMAGE_PATH = "article/par/event-details/secondaryImage";

    final String COMPONENT_DETAILS_NAME = "event-details";
    final String componentPath = "./"+PATH_DEFAULT_CONTENT+"/" + COMPONENT_DETAILS_NAME;

    /***
     * substitute formatted field template with fields from component
     * @param componentProperties source map with fields
     * @param i18n
     * @param sling
     * @return returns map with new values
     */

    public Map processComponentFields(ComponentProperties componentProperties, I18n i18n, SlingScriptHelper sling) {
        Map newFields = new HashMap();

        String formattedTitle = compileComponentMessage(FIELD_FORMAT_TITLE, DEFAULT_FORMAT_TITLE, componentProperties, sling);
        Document fragment = Jsoup.parse(formattedTitle);
        String formattedTitleText = fragment.text();

        newFields.put(FIELD_FORMATTED_TITLE,
                formattedTitle.trim()
        );
        newFields.put(FIELD_FORMATTED_TITLE_TEXT,
                formattedTitleText.trim()
        );
        Calendar eventStartDate = componentProperties.get("eventStartDate",Calendar.getInstance());
        Calendar eventEndDate = componentProperties.get("eventEndDate",Calendar.getInstance());
        String selectedEventTimeFormat = componentProperties.get("eventTimeFormat", StringUtils.EMPTY);

        newFields.put("isPastEventDate", eventEndDate.before(Calendar.getInstance()));

        newFields.put("eventStartDate",eventStartDate);
        newFields.put("eventEndDate",eventEndDate);

        SimpleDateFormat dateFormatString = new SimpleDateFormat(EVENT_DISPLAY_DATE_FORMAT_ISO);

        Date startDateTime = eventStartDate.getTime();
        Date endDateTime = eventEndDate.getTime();

        newFields.put("eventStartDateISO",dateFormatString.format(startDateTime));
        newFields.put("eventEndDateISO",dateFormatString.format(endDateTime));

        SimpleDateFormat dateFormat = new SimpleDateFormat(EVENT_DISPLAY_DATE_FORMAT);
        String eventStartDateText = dateFormat.format(startDateTime);
        String eventEndDateText = dateFormat.format(endDateTime);

        String eventStartDateUppercase = dateFormat.format(startDateTime).toUpperCase();
        String eventEndDateUppercase = dateFormat.format(endDateTime).toUpperCase();

        String eventStartDateLowercase = dateFormat.format(startDateTime).toLowerCase();
        String eventEndDateLowercase = dateFormat.format(endDateTime).toLowerCase();

        newFields.put("eventStartDateText",eventStartDateText);
        newFields.put("eventEndDateText",eventEndDateText);

        newFields.put("eventStartDateUppercase",eventStartDateUppercase);
        newFields.put("eventEndDateUppercase",eventEndDateUppercase);

        newFields.put("eventStartDateLowercase",eventStartDateLowercase);
        newFields.put("eventEndDateLowercase",eventEndDateLowercase);

        if(!selectedEventTimeFormat.equals(EVENT_TIME_DEFAULT_FORMAT)){
           selectedEventTimeFormat = getTagValueAsAdmin(selectedEventTimeFormat,sling);
        }

        SimpleDateFormat timeFormat = new SimpleDateFormat(selectedEventTimeFormat);
        SimpleDateFormat minTimeFormat = new SimpleDateFormat(MINUTES_TIME_FORMAT);
        SimpleDateFormat hourTimeFormat = new SimpleDateFormat(HOURS_TIME_FORMAT);

        String eventStartTimeText = timeFormat.format(startDateTime);
        String eventEndTimeText = timeFormat.format(endDateTime);

        String startTimeMinutes = minTimeFormat.format(startDateTime);
        String endTimeMinutes = minTimeFormat.format(endDateTime);

        String eventStartTimeMinFormatted = timeFormat.format(startDateTime).toLowerCase();
        String eventEndTimeMinFormatted = timeFormat.format(endDateTime).toLowerCase();

        if (startTimeMinutes.equals(TIME_ZERO_FORMAT)) {
            eventStartTimeMinFormatted = hourTimeFormat.format(startDateTime);
        }

        if (endTimeMinutes.equals(TIME_ZERO_FORMAT)) {
            eventEndTimeMinFormatted = hourTimeFormat.format(endDateTime);
        }

        newFields.put("eventStartTimeText",eventStartTimeText);
        newFields.put("eventEndTimeText",eventEndTimeText);

        newFields.put("eventStartTimeUppercase",eventStartTimeText.toUpperCase());
        newFields.put("eventEndTimeUppercase",eventEndTimeText.toUpperCase());

        newFields.put("eventStartTimeLowercase",eventStartTimeText.toLowerCase());
        newFields.put("eventEndTimeLowercase",eventEndTimeText.toLowerCase());

        newFields.put("eventStartTimeMinFormatted",eventStartTimeMinFormatted);
        newFields.put("eventEndTimeMinFormatted",eventEndTimeMinFormatted);

        newFields.put("eventStartTimeMinLowerFormatted",eventStartTimeMinFormatted.toLowerCase());
        newFields.put("eventEndTimeMinLowerFormatted",eventEndTimeMinFormatted.toLowerCase());

        newFields.put("eventStartTimeMinUpperFormatted",eventStartTimeMinFormatted.toUpperCase());
        newFields.put("eventEndTimeMinUpperFormatted",eventEndTimeMinFormatted.toUpperCase());

        componentProperties.putAll(newFields);

        newFields.put("titleFormatted",compileComponentMessage("titleFormat",DEFAULT_FORMAT_TITLE,componentProperties,sling));
        newFields.put("subTitleFormatted",compileComponentMessage("subTitleFormat",DEFAULT_FORMAT_SUBTITLE,componentProperties,sling));
        newFields.put("eventDisplayDateFormatted",compileComponentMessage("eventDisplayDateFormat",DEFAULT_FORMAT_DISPLAYDATE,componentProperties,sling));
        newFields.put("eventDisplayTimeFormatted",compileComponentMessage("eventDisplayTimeFormat",DEFAULT_FORMAT_DISPLAYTIME,componentProperties,sling));

        return newFields;
    }
%>
