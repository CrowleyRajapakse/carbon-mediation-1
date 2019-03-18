<!--
 ~ Copyright (c) 2005-2010, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 ~
 ~ WSO2 Inc. licenses this file to you under the Apache License,
 ~ Version 2.0 (the "License"); you may not use this file except
 ~ in compliance with the License.
 ~ You may obtain a copy of the License at
 ~
 ~    http://www.apache.org/licenses/LICENSE-2.0
 ~
 ~ Unless required by applicable law or agreed to in writing,
 ~ software distributed under the License is distributed on an
 ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 ~ KIND, either express or implied.  See the License for the
 ~ specific language governing permissions and limitations
 ~ under the License.
 -->
<%@ page import="org.wso2.carbon.ui.CarbonUIMessage" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="org.wso2.carbon.utils.ServerConstants" %>
<%@ page import="org.wso2.carbon.CarbonConstants" %>
<%@ page import="org.apache.axis2.context.ConfigurationContext" %>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="org.wso2.carbon.ui.CarbonUIUtil" %>
<%@ page import="org.wso2.carbon.application.mgt.synapse.stub.types.carbon.SynapseApplicationMetadata" %>
<%@ page import="org.wso2.carbon.application.mgt.synapse.ui.SynapseAppAdminClient" %>
<%@ page import="org.wso2.carbon.application.mgt.synapse.stub.types.carbon.TaskMetadata" %>
<%@ page import="org.wso2.carbon.application.mgt.synapse.stub.types.carbon.EndpointMetadata" %>
<%@ page import="org.wso2.carbon.mediation.templates.ui.factory.TemplateEditorClientFactory" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://wso2.org/projects/carbon/taglibs/carbontags.jar" prefix="carbon" %>

<!-- This page is included to display messages which are set to request scope or session scope -->
<jsp:include page="../dialog/display_messages.jsp"/>

<%
    String appName = (String) request.getAttribute("appName");

    String backendServerURL = CarbonUIUtil.getServerURL(config.getServletContext(), session);
    ConfigurationContext configContext =
            (ConfigurationContext) config.getServletContext().getAttribute(CarbonConstants.CONFIGURATION_CONTEXT);

    String cookie = (String) session.getAttribute(ServerConstants.ADMIN_SERVICE_COOKIE);

    String BUNDLE = "org.wso2.carbon.application.mgt.synapse.ui.i18n.Resources";
    ResourceBundle bundle = ResourceBundle.getBundle(BUNDLE, request.getLocale());

    SynapseApplicationMetadata synapseMetadata = null;

    String epType = "";
    
    // set session attribute to create Client factory for editor
    session.setAttribute("editorClientFactory",new TemplateEditorClientFactory());
    
    try {
        SynapseAppAdminClient client = new SynapseAppAdminClient(cookie,
                backendServerURL, configContext, request.getLocale());
        synapseMetadata = client.getSynapseAppData(appName);
    } catch (Exception e) {
        response.setStatus(500);
        CarbonUIMessage uiMsg = new CarbonUIMessage(CarbonUIMessage.ERROR, e.getMessage(), e);
        session.setAttribute(CarbonUIMessage.ID, uiMsg);
    }

%>

<fmt:bundle basename="org.wso2.carbon.application.mgt.synapse.ui.i18n.Resources">
<script type="text/javascript">

    function editCAppArtifact(url) {
        CARBON.showConfirmationDialog("The changes will not persist to the CAPP after restart or redeploy. " +
                                      "Do you want to Edit?", function () {
            $.ajax({
                       type: 'POST',
                       success: function () {
                           document.location.href = url;
                       }
                   });
        });
    }

</script>

<%
    if (synapseMetadata != null) {
        String[] proxyServices = synapseMetadata.getProxyServices();
        if (proxyServices != null && proxyServices.length > 0) {
%>
<p>&nbsp;&nbsp;</p>
<table class="styledLeft" id="proxyServicesTable" width="40%">
    <thead>
    <tr>
        <th><img src="../synapse-apps/images/proxy_services.gif" alt="" style="vertical-align:middle;">&nbsp;<fmt:message key="carbonapps.proxy.services"/></th>
        <%--<th><fmt:message key="carbonapps.actions"/></th>--%>
    </tr>
    </thead>
    <tbody>
    <%
        for (String psName : proxyServices) {
    %>
    <tr>
        <td><a href="../service-mgt/service_info.jsp?serviceName=<%= psName%>"><%= psName%></a></td>
        <%--<td><a href="#" class="icon-link-nofloat" style="background-image:url(images/delete.gif);" onclick="deleteArtifact('<%= psName%>', 'proxyservice', '../synapse-apps/delete_synapse_artifact.jsp');" title="<%= bundle.getString("carbonapps.delete.proxy.service")%>"><%= bundle.getString("carbonapps.delete")%></a></td>--%>
    </tr>
    <%
        }
    %>
    </tbody>
</table>
<%
    }
    String[] sequences = synapseMetadata.getSequences();
    if (sequences != null && sequences.length > 0) {
%>
<p>&nbsp;&nbsp;</p>
<table class="styledLeft" id="SequencesTable" width="40%">
    <thead>
    <tr>
        <th><img src="../synapse-apps/images/sequences.gif" alt="" style="vertical-align:middle;">&nbsp;<fmt:message key="carbonapps.sequences"/></th>
        <%--<th><fmt:message key="carbonapps.actions"/></th>--%>
    </tr>
    </thead>
    <tbody>
    <%
        for (String sequenceName : sequences) {
    %>
    <tr>
        <td>
            <a href="#"
               onclick="editCAppArtifact('../sequences/design_sequence.jsp?sequenceAction=edit&sequenceName=<%= Encode.forJavaScriptAttribute(sequenceName) %>')">
                <%= sequenceName%>
            </a>
        </td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>

<%
    }
    EndpointMetadata[] endpoints = synapseMetadata.getEndpoints();
    if (endpoints != null && endpoints.length > 0) {
%>
<p>&nbsp;&nbsp;</p>
<table class="styledLeft" id="EndpointsTable" width="40%">
    <thead>
    <tr>
        <th><img src="../synapse-apps/images/endpoints-icon.gif" alt="" style="vertical-align:middle;">&nbsp;<fmt:message key="carbonapps.endpoints"/></th>
        <%--<th><fmt:message key="carbonapps.actions"/></th>--%>
    </tr>
    </thead>
    <tbody>
    <%
        for (EndpointMetadata epData : endpoints) {
            if (epData.getType().equals("WSDL")) {
                epType = "wsdl";
            }
            else {
                epType = epData.getType();
            }
    %>
    <tr>
        <td>
            <a href="#"
               onclick="editCAppArtifact('../endpoints/<%=epType%>Endpoint.jsp?endpointName=<%= Encode.forJavaScriptAttribute(epData.getName()) %>&endpointAction=edit')">
                <%= epData.getName()%>
            </a>
        </td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>

<%
    }
    String[] localEntries = synapseMetadata.getLocalEntries();
    if (localEntries != null && localEntries.length > 0) {
%>
<p>&nbsp;&nbsp;</p>
<table class="styledLeft" id="LocalEntriesTable" width="40%">
    <thead>
    <tr>
        <th><img src="../synapse-apps/images/localentry-icon.gif" alt="" style="vertical-align:middle;">&nbsp;<fmt:message key="carbonapps.local.entries"/></th>
        <%--<th><fmt:message key="carbonapps.actions"/></th>--%>
    </tr>
    </thead>
    <tbody>
    <%
        for (String leName : localEntries) {
    %>
    <tr>
        <td><a href="../localentries/inlinedXML.jsp?entryName=<%= leName%>"><%= leName%></a></td>
        <%--<td><a href="#" class="icon-link-nofloat" style="background-image:url(images/delete.gif);" onclick="deleteArtifact('<%= leName%>', 'localentry', '../synapse-apps/delete_synapse_artifact.jsp');" title="<%= bundle.getString("carbonapps.delete.local.entry")%>"><%= bundle.getString("carbonapps.delete")%></a></td>--%>
    </tr>
    <%
        }
    %>
    </tbody>
</table>

<%
    }

    String[] msgStores = synapseMetadata.getMessageStores();
    if (msgStores != null && msgStores.length > 0) {
%>
<p>&nbsp;&nbsp;</p>
<table class="styledLeft" id="MessageStoreTable" width="40%">
    <thead>
    <tr>
        <th><img src="../message_store/images/message_store.gif" alt="" style="vertical-align:middle;">&nbsp;<fmt:message key="carbonapps.message.stores"/></th>
    </tr>
    </thead>
    <tbody>
    <%
        for (String msgStore : msgStores) {
    %>
    <tr>
        <td>
            <a href="#"
               onclick="editCAppArtifact('../message_store/jmsMessageStore.jsp?messageStoreName=<%= msgStore%>')">
                <%= msgStore%>
            </a>
        </td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>

<%
    }

    String[] msgProcessors = synapseMetadata.getMessageProcessors();
    if (msgProcessors != null && msgProcessors.length > 0) {
%>
<p>&nbsp;&nbsp;</p>
<table class="styledLeft" id="MessageProcessorTable" width="40%">
    <thead>
    <tr>
        <th><img src="../message_processor/images/message-processor.gif" alt="" style="vertical-align:middle;">&nbsp;<fmt:message key="carbonapps.message.processors"/></th>
    </tr>
    </thead>
    <tbody>
    <%
        for (String msgProcessor : msgProcessors) {
    %>
    <tr>
        <td><a href="../message_processor/manageMessageForwardingProcessor.jsp?messageProcessorName=<%= msgProcessor%>"><%= msgProcessor%></a></td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>

<%
    }
    String[] events = synapseMetadata.getEvents();
    if (events != null && events.length > 0) {
%>
<p>&nbsp;&nbsp;</p>
<table class="styledLeft" id="EventsTable" width="40%">
    <thead>
    <tr>
        <th><img src="../synapse-apps/images/event-sources.gif" alt="" style="vertical-align:middle;">&nbsp;<fmt:message key="carbonapps.events"/></th>
        <%--<th><fmt:message key="carbonapps.actions"/></th>--%>
    </tr>
    </thead>
    <tbody>
    <%
        for (String eventName : events) {
    %>
    <tr>
        <td><a href="../event-source/event_source_details.jsp?eventsource=<%= eventName%>"><%= eventName%></a></td>
        <%--<td><a href="#" class="icon-link-nofloat" style="background-image:url(images/delete.gif);" onclick="deleteArtifact('<%= eventName%>', 'event', '../synapse-apps/delete_synapse_artifact.jsp');" title="<%= bundle.getString("carbonapps.delete.events")%>"><%= bundle.getString("carbonapps.delete")%></a></td>--%>
    </tr>
    <%
        }
    %>
    </tbody>
</table>

<%
    }
    TaskMetadata[] tasks = synapseMetadata.getTasks();
    if (tasks != null && tasks.length > 0) {
%>
<p>&nbsp;&nbsp;</p>
<table class="styledLeft" id="EventsTable" width="40%">
    <thead>
    <tr>
        <th><img src="../synapse-apps/images/tasks-icon.gif" alt="" style="vertical-align:middle;">&nbsp;<fmt:message key="carbonapps.tasks"/></th>
        <%--<th><fmt:message key="carbonapps.actions"/></th>--%>
    </tr>
    </thead>
    <tbody>
    <%
        for (TaskMetadata taskData : tasks) {
    %>
    <tr>
        <td><a href="../task/edittask.jsp?taskName=<%= taskData.getName()%>&taskGroup=<%= taskData.getGroupName()%>"><%= taskData.getName()%></a></td>
        <%--<td><a href="#" class="icon-link-nofloat" style="background-image:url(images/delete.gif);" onclick="deleteArtifact('<%= taskData.getName()%>', 'task', '../synapse-apps/delete_synapse_artifact.jsp');" title="<%= bundle.getString("carbonapps.delete.tasks")%>"><%= bundle.getString("carbonapps.delete")%></a></td>--%>
    </tr>
    <%
        }
    %>
    </tbody>
</table>

<%
    }
    String[] mediators = synapseMetadata.getMediators();
    if (mediators != null && mediators.length > 0) {
%>
<p>&nbsp;&nbsp;</p>
<table class="styledLeft" id="MediatorsTable" width="40%">
    <thead>
    <tr>
        <th><img src="../sequences/images/mediation-icon.gif" alt="" style="vertical-align:middle;">&nbsp;<fmt:message key="carbonapps.mediators"/></th>
    </tr>
    </thead>
    <tbody>
    <%
        for (String mediator : mediators) {
    %>
    <tr>
        <td><%= mediator%></td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>

<%
    }

    String[] inboundEps = synapseMetadata.getInboundEPs();
    if (inboundEps != null && inboundEps.length > 0) {
%>
<p>&nbsp;&nbsp;</p>
<table class="styledLeft" id="InboundEPTable" width="40%">
    <thead>
    <tr>
        <th><img src="../inbound/images/inbound-icon.gif" alt="" style="vertical-align:middle;">&nbsp;<fmt:message key="carbonapps.inboundEndpoints"/></th>
    </tr>
    </thead>
    <tbody>
    <%
        for (String inboundEp : inboundEps) {
    %>
    <tr>
        <td><a href="../inbound/editInbound.jsp?name=<%= inboundEp%>"><%= inboundEp%></a></td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>

<%
    }
    String[] apis = synapseMetadata.getApis();
        if (apis != null && apis.length > 0) {
%>
<p>&nbsp;&nbsp;</p>
<table class="styledLeft" id="APITable" width="40%">
    <thead>
    <tr>
        <th><img src="../api/images/api-icon.png" alt="" style="vertical-align:middle;">&nbsp;<fmt:message key="carbonapps.apis"/></th>
    </tr>
    </thead>
    <tbody>
    <%
        for (String api : apis) {
    %>
    <tr>
        <td>
            <a href="#"
               onclick="editCAppArtifact('../api/manageAPI.jsp?mode=edit&apiName=<%= Encode.forJavaScriptAttribute(api) %>')"><%= api%>
            </a>
        </td>
    </tr>
    <%
    }
%>
    </tbody>
</table>

<%
    }
    String[] templates = synapseMetadata.getTemplates();
    if (templates != null && templates.length > 0) {
%>
<p>&nbsp;&nbsp;</p>
<table class="styledLeft" id="TemplatesTable" width="40%">
    <thead>
    <tr>
        <th><img src="../templates/images/sequences.gif" alt="" style="vertical-align:middle;">&nbsp;<fmt:message key="carbonapps.templates"/></th>
    </tr>
    </thead>
    <tbody>
    <%
        for (String templateName : templates) {
    %>
    <tr>
        <td>
            <a href="#"
               onclick="editCAppArtifact('../sequences/design_sequence.jsp?sequenceAction=edit&seqEditor=template&sequenceName=<%= Encode.forJavaScriptAttribute(templateName) %>')"><%= templateName%>
    
            </a>
        </td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>
<%
    }

    }
%>
</fmt:bundle>
