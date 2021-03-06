/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 ~ Copyright 2017 Adobe Systems Incorporated
 ~
 ~ Licensed under the Apache License, Version 2.0 (the "License");
 ~ you may not use this file except in compliance with the License.
 ~ You may obtain a copy of the License at
 ~
 ~   http://www.apache.org/licenses/LICENSE-2.0
 ~
 ~ Unless required by applicable law or agreed to in writing, software
 ~ distributed under the License is distributed on an "AS IS" BASIS,
 ~ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ~ See the License for the specific language governing permissions and
 ~ limitations under the License.
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
package design.aem.models.v3.content;

import ch.qos.logback.classic.Logger;
import com.adobe.cq.sightly.SightlyWCMMode;
import com.adobe.cq.sightly.WCMBindings;
import com.adobe.cq.wcm.core.components.models.Image;
import com.adobe.cq.wcm.core.components.testing.MockContentPolicyStyle;
import com.day.cq.commons.Externalizer;
import com.day.cq.wcm.api.Page;
import com.day.cq.wcm.api.designer.Style;
import com.day.cq.wcm.api.policies.ContentPolicy;
import com.day.cq.wcm.api.policies.ContentPolicyMapping;
import design.aem.context.CoreComponentTestContext;
import io.wcm.testing.mock.aem.junit.AemContext;
import org.apache.commons.lang3.StringUtils;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ValueMap;
import org.apache.sling.api.scripting.SlingBindings;
import org.apache.sling.testing.mock.sling.ResourceResolverType;
import org.apache.sling.testing.mock.sling.junit.SlingContext;
import org.apache.sling.testing.mock.sling.servlet.MockSlingHttpServletRequest;
import org.apache.sling.testing.mock.sling.servlet.MockSlingHttpServletResponse;
import org.junit.Before;
import org.junit.ClassRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Matchers;
import org.mockito.runners.MockitoJUnitRunner;
import org.slf4j.LoggerFactory;

import static design.aem.utils.components.CommonUtilTest.getTestBase;
import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.junit.Assert.assertEquals;

@RunWith(MockitoJUnitRunner.class)
public class ImageImplTest {

    private static final Logger LOGGER = (Logger) LoggerFactory.getLogger(ImageImplTest.class);

    protected static final String ROOT = "/asset";
    protected static final String CONTENT = ROOT + "/image";
    protected static final String IMAGE_01_PATH = ROOT + "/image/jcr:content/article/par/contentblock1/par/image";
    protected static String CONTEXT_PATH = "/core";

    MockSlingHttpServletRequest request;
    MockSlingHttpServletResponse response;
    private Resource testResource;

    @ClassRule
    public static final AemContext CONTEXT = CoreComponentTestContext.createContext(ROOT,ROOT);

    @Before
    public void setUp() throws Exception {
        request = new MockSlingHttpServletRequest(CONTEXT.resourceResolver(), CONTEXT.bundleContext());
        response = new MockSlingHttpServletResponse();

        testResource = CONTEXT.resourceResolver().getResource(IMAGE_01_PATH);
        if (testResource == null) {
            throw new IllegalStateException("Did you forget to define test resource " + IMAGE_01_PATH + "?");
        }
    }


    @Test
    public void testClass() {
        // Run the test
        ImageImpl test = new ImageImpl();

        // Verify the results
        assertNotNull(test);
    }


}
