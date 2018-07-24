package design.aem.impl.jobs;


import com.adobe.granite.asset.api.Asset;
import com.day.cq.commons.Externalizer;
import com.day.cq.search.QueryBuilder;
import design.aem.utils.AssetUtil;
import design.aem.utils.QueryBuilderUtil;
import design.aem.utils.UserManagementUtil;
import design.aem.utils.WorkflowUtil;
import org.apache.commons.lang3.StringUtils;
import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Properties;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.jackrabbit.api.security.user.Authorizable;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.resource.ResourceResolverFactory;
import org.apache.sling.event.jobs.Job;
import org.apache.sling.event.jobs.consumer.JobExecutionContext;
import org.apache.sling.event.jobs.consumer.JobExecutionResult;
import org.apache.sling.event.jobs.consumer.JobExecutor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.jcr.RepositoryException;
import javax.jcr.Session;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;

@Component
@Service
@Properties({
        @Property(name = "job.topics", value = {"aemdesign/granite/maintenance/job/AssetExpiringReviewTask"}, propertyPrivate = true),
        @Property(name = "granite.maintenance.name", value = {"design.aem.impl.jobs.AssetExpiringReviewTask"}, propertyPrivate = true),
        @Property(name = "granite.maintenance.title", value = {"Expired Asset Review Notification"}, propertyPrivate = true),
        @Property(name = "granite.maintenance.schedule", value = {"weekly"}),
        @Property(name = "granite.maintenance.isConservative", boolValue = {false})
})
public class AssetExpiringReviewTask implements JobExecutor {

  private static final Logger log = LoggerFactory.getLogger(AssetExpiringReviewTask.class);

  private static final String WORKFLOW_MODEL_PATH = "/etc/workflow/models/aemdesign/asset-review-expiring-workflow/jcr:content/model";

  private static final String REPORT_LINK = "/mnt/overlay/dam/gui/content/reports/reportsresult.html/apps/dam/content/reports/samplereports/assetreviewreport?orderby=path&p.limit=-1&_charset_=utf-8&_dc=&0_relativedaterange.upperBound=1M&0_relativedaterange.lowerBound=-100y&0_relativedaterange.property=jcr%3Acontent%2Fmetadata%2Fasset.date.review&type=dam%3AAsset&path=%2Fcontent%2Fdam&_=";

  @Reference
  private ResourceResolverFactory resourceResolverFactory;

  @Reference
  private QueryBuilder queryBuilder;

  @SuppressWarnings("Duplicates")
  @Override
  public JobExecutionResult process(Job job, JobExecutionContext jobExecutionContext) {
    log.info("Expiring Asset Licenses Notification task triggered");

    try {
      ResourceResolver resourceResolver = resourceResolverFactory.getResourceResolver(null);

      Map<Authorizable, Collection<String>> assetOwnerToPathsMap = new LinkedHashMap<>();
      for (String path : collectExpiringAssetPaths(resourceResolver.adaptTo(Session.class))) {
        Asset asset = AssetUtil.getAsset(resourceResolver, path);
        Authorizable owner = AssetUtil.getAssetOwner(asset);

        Collection<String> paths = assetOwnerToPathsMap.computeIfAbsent(owner, s -> new LinkedHashSet<>());
        paths.add(asset.getPath());
      }


      Externalizer externalizer = resourceResolver.adaptTo(Externalizer.class);
      String authorPath = externalizer.authorLink(resourceResolver, "/");

      for (Map.Entry<Authorizable, Collection<String>> entry : assetOwnerToPathsMap.entrySet()) {
        Collection<String> paths = entry.getValue();

        Map<String, Object> wfMetadata = new LinkedHashMap<>();

        String pathList = "";

        if (paths.size() > 0) {
          for (String path : paths) {
            if (StringUtils.isNotEmpty(path)) {
              String href = authorPath + "assetdetails.html" + path;
              pathList += "<li><a href=\"" + href + "\">" + path + "</a></li>";
            }

          }

        }

        pathList = "<ul>" + pathList + "</ul>";

        Authorizable owner = entry.getKey();
        wfMetadata.put("pathList", pathList);
        wfMetadata.put("paths", paths.toArray(new String[paths.size()]));
        wfMetadata.put("username", UserManagementUtil.getDisplayName(resourceResolver, owner.getID()));
        wfMetadata.put("toEmail", UserManagementUtil.getNameAndEmail(resourceResolver, owner));
        wfMetadata.put("reportLink", REPORT_LINK);

        WorkflowUtil.start(resourceResolver, WORKFLOW_MODEL_PATH, wfMetadata);
      }

      return jobExecutionContext.result().succeeded();
    } catch (Exception ex) {
      log.error("Expiring Asset Licenses Notification error, {}", ex);
    }

    return jobExecutionContext.result().failed();
  }

  private Collection<String> collectExpiringAssetPaths(Session session) throws RepositoryException {
    Map<String, String> queryMap = new LinkedHashMap<>();

        /*
            path=/content/dam
            type=dam:Asset
            orderby=path
            0_relativedaterange.upperBound=1M
            0_relativedaterange.lowerBound=-100y
            0_relativedaterange.property=jcr:content/metadata/asset.date.review

            http://localhost:4502/libs/cq/search/content/querydebug.html?_charset_=UTF-8&query=path%3D%2Fcontent%2Fdam%0D%0Atype%3Ddam%3AAsset%0D%0Aorderby%3Dpath%0D%0A0_relativedaterange.upperBound%3D1M%0D%0A0_relativedaterange.lowerBound%3D-100y%0D%0A0_relativedaterange.property%3Djcr%3Acontent%2Fmetadata%2Fasset.date.review

         */
    queryMap.put("path", "/content/dam");
    queryMap.put("type", "dam:Asset");
    queryMap.put("orderby", "path");
    queryMap.put("0_relativedaterange.upperBound", "1M");
    queryMap.put("0_relativedaterange.lowerBound", "-100y");
    queryMap.put("0_relativedaterange.property", "jcr:content/metadata/asset.date.review");
    return QueryBuilderUtil.queryForPaths(queryBuilder, session, queryMap);
  }

}
