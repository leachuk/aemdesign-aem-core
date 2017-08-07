//download - behaviour
window.AEMDESIGN = window.AEMDESIGN || {"jQuery":{}};
window.AEMDESIGN.components = AEMDESIGN.components || {};
window.AEMDESIGN.components.download = AEMDESIGN.components.download || {};


(function ($, _, ko, ns, analytics, window, undefined) { //add additional dependencies


    $(document).ready(function () {
        $("a.download[data-analytics-type=aa]").each(function() {
            var link = $(this);
            analytics.enableAA(link);
        });
        $("a.download[data-analytics-type=ga]").each(function() {
            var link = $(this);
            analytics.enableGA(link);
        });
        $("div.download[data-analytics-type=aa]").each(function() {
            var link = $(this).find("a");
            analytics.enableAA(link);
        });
        $("div.download[data-analytics-type=ga]").each(function() {
            var link = $(this).find("a");
            analytics.enableGA(link);
        });
    })


})(AEMDESIGN.jQuery, _, ko, AEMDESIGN.components.download, AEMDESIGN.analytics, this); //pass in additional dependencies
