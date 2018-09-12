<%@ page import="com.day.cq.commons.ImageResource" %>
<%@ page import="org.apache.commons.lang3.math.NumberUtils" %>
<%@ page import="java.net.URI" %>
<%!

    final static String I18N_CATEGORY = "image";
    final static String I18N_FORMAT_DIRECTOR = "directorLine";

    final static String RENDITION_PROFILE_CUSTOM = "cq5dam.custom.";

    final static String RENDITION_REGEX_PATTERN = "^(\\w*)\\.(\\w*)\\.(\\d*)\\.(\\d*)\\.(\\S{3,4})$";

    //this is used to store admin config for image component
    final static String OSGI_CONFIG_MEDIA_IMAGE = "aemdesign.components.media.image";

    /**
     * Get the allowedDimension for the Image
     * @param targetDimension
     * @param _currentStyle
     * @return
     */
    public Integer getDimension(Integer targetDimension, Style _currentStyle){
        Integer dimension = null;
        if (targetDimension != null && targetDimension.intValue() > 0) {
            int max = _currentStyle.get(Image.PN_MAX_WIDTH,Integer.class);
            int min = _currentStyle.get(Image.PN_MIN_WIDTH,Integer.class);
            if (min <= targetDimension && targetDimension <= max){
                dimension = targetDimension;

            }else if (min > targetDimension){
//                image.set(Image.PN_HTML_WIDTH, String.valueOf(min));

                dimension = min;
            }else if (max < targetDimension){
//                image.set(Image.PN_HTML_WIDTH, String.valueOf(max));
                dimension = max;
            }
        }
        return dimension;
    }

    /***
     * function to filter out the design dialog values which are not matching rendition profile using default rendition prefix names
     * @param asset asset to use
     * @param widthRenditionProfileMapping profile widths map
     * @return
     */
    public Map<Integer, String> getBestFitRenditionSet(com.adobe.granite.asset.api.Asset asset,  Map<Integer, String> widthRenditionProfileMapping) {
        return getBestFitRenditionSet(asset,widthRenditionProfileMapping,null);
    }

    /**
     * function to filter out the design dialog values which are not matching rendition profile
     * @param asset asset to use
     * @param widthRenditionProfileMapping profile widths map
     * @param renditionPrefix prefix to use
     * @return Map<Integer, String> return profile with substituted paths
     */
    public Map<Integer, String> getBestFitRenditionSet(com.adobe.granite.asset.api.Asset asset,  Map<Integer, String> widthRenditionProfileMapping, String renditionPrefix){

        Map<Integer, String> profileRendtiions = new TreeMap<Integer, String>();

        if (isEmpty(renditionPrefix))

        if (asset != null && widthRenditionProfileMapping != null) {

            for (Integer minWidth : widthRenditionProfileMapping.keySet()) {
                String profileWidth = widthRenditionProfileMapping.get(minWidth);
                com.adobe.granite.asset.api.Rendition rendition = getBestFitRendition( tryParseInt(profileWidth,0), asset, defaultIfEmpty(renditionPrefix,null));

//                LOG.warn("Best Rendition: [" + tryParseInt(profileWidth,0) + "] found rendition : [" + rendition.getPath() + "] profile name : " + profileWidth );

                String renditionPath = rendition.getPath();

                //don't return paths to original rendition return path to asset instead
                if (renditionPath.endsWith("/original")) {
                    String assetPath = renditionPath.substring(0,renditionPath.indexOf(JcrConstants.JCR_CONTENT)-1);
                    ResourceResolver resourceResolver = asset.getResourceResolver();
                    if (resourceResolver != null) {
                        Resource assetPathResource = resourceResolver.resolve(assetPath);
                        if (!ResourceUtil.isNonExistingResource(assetPathResource)) {
                            renditionPath = assetPath;
                        }
                    }
                }

                profileRendtiions.put(minWidth,renditionPath);
            }

        }
            return profileRendtiions;

    }
    /**
     * function to filter out the design dialog values which are not matching rendition profile
     * @param asset asset to use
     * @param renditionImageMapping array of minWidth=mediaQuery
     * @param renditionPrefix prefix to use
     * @return Map<Integer, String> return profile with substituted paths
     */
    public Map<String, String> getBestFitMediaQueryRenditionSet(com.adobe.granite.asset.api.Asset asset,  String[] renditionImageMapping, String renditionPrefix){

        Map<String, String> profileRendtiions = new LinkedHashMap<String, String>();

        if (isEmpty(renditionPrefix))

        if (asset != null && renditionImageMapping != null) {

            for (String entry : renditionImageMapping){
                String [] entryArray = StringUtils.split(entry, "=");
                if (entryArray == null || entryArray.length != 2){
                    LOG.error("getBestFitMediaQueryRenditionSet ["+entry+"] is invalid");
                    continue;
                }
                String minWidth = entryArray[0];
                if (StringUtils.isEmpty(minWidth)  || (NumberUtils.isDigits(minWidth) == false)){
                    LOG.error("getBestFitMediaQueryRenditionSet ["+entry+"] is invalid, incorrect width ["+minWidth+"]");
                    continue;
                }

                String mediaQuery = entryArray[1];

                com.adobe.granite.asset.api.Rendition rendition = getBestFitRendition( tryParseInt(minWidth,0), asset, defaultIfEmpty(renditionPrefix,null));

                String renditionPath = rendition.getPath();

                //don't return paths to original rendition return path to asset instead
                if (renditionPath.endsWith("/original")) {
                    String assetPath = renditionPath.substring(0,renditionPath.indexOf(JcrConstants.JCR_CONTENT)-1);
                    ResourceResolver resourceResolver = asset.getResourceResolver();
                    if (resourceResolver != null) {
                        Resource assetPathResource = resourceResolver.resolve(assetPath);
                        if (!ResourceUtil.isNonExistingResource(assetPathResource)) {
                            renditionPath = assetPath;
                        }
                    }
                }

                profileRendtiions.put(mediaQuery,renditionPath);
            }

        }
            return profileRendtiions;

    }

    /**
     * Get the targetWith which is within the range from the Site
     * @param style
     * @param targetWidth
     * @return
     */
    public Map<Integer, String> getWidthProfileMap(Style style, int targetWidth){

        Map<Integer, String> widthRenditionProfileMap = new LinkedHashMap<Integer, String>();

        Integer maxWidth = style.get(ImageResource.PN_MAX_WIDTH, Integer.class);
        Integer minWidth = style.get(ImageResource.PN_MIN_WIDTH, Integer.class);

        targetWidth = Math.min(targetWidth, maxWidth);
        targetWidth = Math.max(targetWidth, minWidth);
        widthRenditionProfileMap.put(targetWidth, String.valueOf(targetWidth));

        return widthRenditionProfileMap;
    }


    /**
     * Validate the List of the widthImageMapping from Design dialog and convert it into Map<Integer, String>
     * @param widthImageMapping
     * @return Map<Integer, String>
     * @throws IllegalAccessException
     */
    public Map<Integer, String> getWidthProfileMap(String [] widthImageMapping) throws IllegalAccessException{

        Map<Integer, String> widthRenditionProfileMap = new LinkedHashMap<Integer, String>();


        if (widthImageMapping != null && widthImageMapping.length > 0){

            for (String entry : widthImageMapping){
                String [] entryArray = StringUtils.split(entry, "=");
                if (entryArray == null || entryArray.length != 2){
                    LOG.error("design widthImageMapping ["+entry+"] is invalid");
                    new IllegalAccessException("design widthImageMapping ["+entry+"] is invalid");
                }
                String imageWidth = entryArray[0];
                if (StringUtils.isEmpty(imageWidth)){
                    LOG.error("profile ["+imageWidth+"] is invalid");
                    new IllegalAccessException("imageWidth ["+imageWidth+"] is invalid");
                }
                String minWidth = entryArray[1];
                if (StringUtils.isEmpty(minWidth)  || (NumberUtils.isDigits(minWidth) == false)){
                    LOG.error("minWidth ["+minWidth+"] is invalid");
                    new IllegalAccessException("minWidth ["+minWidth+"] is invalid");
                }

                widthRenditionProfileMap.put(Integer.valueOf(minWidth), imageWidth);

            }
        }

        return widthRenditionProfileMap;
    }


    /**
     * function to filter out the design dialog values which are not matching adaptive profile
     * @param adaptiveImageMapping
     * @param resolver
     * @param componentPath path to component doing the render
     * @param fileReference path to asset to use for render
     * @param outputFormat specify which output format to use
     * @param useFileReferencePathAsRender create paths using fileReference instead of using Component Path
     * @param sling
     * @return Map<Integer, String>
     */
    public Map<String, String> getAdaptiveImageSet (String[] adaptiveImageMapping, ResourceResolver resolver, String componentPath, String fileReference, String outputFormat, Boolean useFileReferencePathAsRender, org.apache.sling.api.scripting.SlingScriptHelper sling){

        Map<String, String> responsiveImageSet = new LinkedHashMap<String, String>();

        URI fileReferenceURI  = URI.create(fileReference);
        if (isBlank(outputFormat)) {
            String extension = fileReferenceURI.getPath();
            outputFormat = extension.substring(extension.lastIndexOf("."));
        }
        String suffix = defaultString(fileReferenceURI.getQuery(), "");

        String renderPath = componentPath;

        if (useFileReferencePathAsRender) {
            renderPath = fileReference;
        }

        int[] allowedSizes = getAdaptiveImageSupportedWidths(sling);

        for (String entry : adaptiveImageMapping){

            String [] entryArray = StringUtils.split(entry, "="); //320.medium=(min-width: 1px) and (max-width: 425px)
            if (entryArray == null || entryArray.length != 2){
                LOG.error("getAdaptiveImageSet ["+entry+"] is invalid");
                continue;
            }
            String adaptiveProfile = entryArray[0];
            if (StringUtils.isEmpty(adaptiveProfile) && (!adaptiveProfile.contains(".")) ){
                LOG.error("getAdaptiveImageSet ["+entry+"] is invalid, incorrect profile format ["+adaptiveProfile+"] expecting {width}.{quality}.{format}");
                continue;
            }

            String mediaQuery = entryArray[1];

            String [] adaptiveProfileArray = StringUtils.split(adaptiveProfile, ".");

            Integer profileWidth = tryParseInt(adaptiveProfileArray[0],0);

            String profileOutputFormat = outputFormat;
            if (adaptiveProfileArray.length == 3) {
                profileOutputFormat = "";
            }

            if (adaptiveProfile.equals("full") || ArrayUtils.contains(allowedSizes,profileWidth) ) {
                responsiveImageSet.put(mediaQuery,
                        MessageFormat.format("{0}.img.{1}{2}{3}",
                                renderPath,
                                adaptiveProfile,
                                profileOutputFormat,
                                suffix
                        )
                );
            } else {
                LOG.error("getAdaptiveImageSet rendition selected size is not allowed ["+profileWidth+"], ["+entry+"]");
                continue;
            }

        }

        return responsiveImageSet;
    }

    /**
     * return list of configured widths in com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet
     * @param sling
     * @return int []
     */
    public int []  getAdaptiveImageSupportedWidths(org.apache.sling.api.scripting.SlingScriptHelper sling) {

        int [] defaultWidths  = {480,640,720,800,960,1024,1280};
        int [] supportedWidths = new int[0];

        try{
            org.osgi.service.cm.ConfigurationAdmin configAdmin = sling.getService(org.osgi.service.cm.ConfigurationAdmin.class);

            org.osgi.service.cm.Configuration config = configAdmin.getConfiguration(OSGI_CONFIG_MEDIA_IMAGE);

            Object obj = org.apache.sling.commons.osgi.PropertiesUtil.toStringArray(config.getProperties().get("adapt.supported.widths"));

            if (obj instanceof String []){

                String[] strings = (String [])obj;
                supportedWidths = new int[strings.length];
                for (int i=0; i < strings.length; i++) {
                    supportedWidths[i] = Integer.parseInt(strings[i]);
                }
            }

            if (obj instanceof long []){

                long [] longs = (long [])obj;
                supportedWidths = new int[longs.length];
                for (int i=0; i < longs.length; i++) {
                    supportedWidths[i] = (int)longs[i];
                }
            }

        } catch(Exception ex){
            LOG.warn("using default adapt.supported.widths=[{}] as config is missing OSGI configuration: {}", defaultWidths, OSGI_CONFIG_MEDIA_IMAGE);
            return defaultWidths;
        }
        return supportedWidths;

    }



/* TESTS
    out.println("responsiveRenditionOverride : "+widthRenditionProfileMapping);
    out.println("responsiveRenditionOverride1 : "+responsiveImageSet);
    out.println("filterRenditionImageSet(asset, widthRenditionProfileMapping, RENDITION_PROFILE_CUSTOM) : \n"+filterRenditionImageSet(asset, widthRenditionProfileMapping, RENDITION_PROFILE_CUSTOM));
    out.println("filterRenditionImageSet(asset, widthRenditionProfileMapping, \"cq5dam.custom.\") : \n"+filterRenditionImageSet(asset, widthRenditionProfileMapping, "cq5dam.custom."));
    out.println("getBestFitRendition(48, asset) : \n" + getBestFitRendition(48, asset) );
    out.println("getBestFitRendition(48, asset, RENDITION_PROFILE_CUSTOM) : \n" + getBestFitRendition(48, asset, RENDITION_PROFILE_CUSTOM) );
    out.println("getBestFitRendition(48, asset, \"cq5dam.custom.\") : \n" + getBestFitRendition(48, asset, "cq5dam.custom.") );
    out.println("getBestFitRendition(319, asset, \"cq5dam.custom.\") : \n" + getBestFitRendition(319, asset, "cq5dam.custom.") );
    out.println("getBestFitRendition(1900, asset, \"cq5dam.custom.\") : \n" + getBestFitRendition(1900, asset, "cq5dam.custom.") );
    out.println("getBestFitRendition(1280, asset, RENDITION_PROFILE_CUSTOM) : \n" + getBestFitRendition(1280, asset, RENDITION_PROFILE_CUSTOM) );
    out.println("getBestFitRendition(47, asset, RENDITION_PROFILE_CUSTOM) : \n" + getBestFitRendition(47, asset, RENDITION_PROFILE_CUSTOM) );
    out.println("getBestFitRendition(49, asset, \"cq5dam.custom.\") : \n" + getBestFitRendition(49, asset, "cq5dam.custom.") );
    out.println("getBestFitRendition(47, asset) : \n" + getBestFitRendition(47, asset) );
    out.println("getBestFitRendition(48, asset) : \n" + getBestFitRendition(48, asset) );
    out.println("getBestFitRendition(49, asset) : \n" + getBestFitRendition(49, asset) );
    out.println("getBestFitRendition(139, asset) : \n" + getBestFitRendition(139, asset) );
    out.println("getBestFitRendition(140, asset) : \n" + getBestFitRendition(140, asset) );
    out.println("getBestFitRendition(141, asset) : \n" + getBestFitRendition(141, asset) );
    out.println("getBestFitRendition(318, asset) : \n" + getBestFitRendition(318, asset) );
    out.println("getBestFitRendition(319, asset) : \n" + getBestFitRendition(319, asset) );
    out.println("getBestFitRendition(320, asset) : \n" + getBestFitRendition(320, asset) );
    out.println("getBestFitRendition(1279, asset) : \n" + getBestFitRendition(1279, asset) );
    out.println("getBestFitRendition(1280, asset) : \n" + getBestFitRendition(1280, asset) );
    out.println("getBestFitRendition(1281, asset) : \n" + getBestFitRendition(1281, asset) );
*/
%>