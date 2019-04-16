<div ${componentProperties.componentAttributes} itemscope itemtype="https://schema.org/WebSite">
    <form action="${componentProperties.formAction}" method="${componentProperties.formMethod}" novalidate="" role="form search" itemprop="potentialAction" itemscope itemtype="https://schema.org/SearchAction">
        <meta itemprop="target" content="${componentProperties.formAction}?q={${componentProperties.formParameterName}}"/>
        <fieldset>
            <legend hidden="">${componentProperties.legendText}</legend> <label for="nav_search" hidden="">${componentProperties.labelText}</label>
            <input itemprop="query-input" autocomplete="off" id="nav_search" name="${componentProperties.formParameterName}" placeholder="${componentProperties.placeholderText}" type="search"> <input type="submit" value="${componentProperties.searchButtonText}">
        </fieldset>
    </form>
</div>