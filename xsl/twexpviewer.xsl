<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="twexpviewer_ui.xsl"/>
	<xsl:import href="twexpviewer_doc.xsl"/>
	<!--xsl:output method="html" version="4.0" encoding="UTF-8" indent="no"/-->
	<xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="no"/>

 	<xsl:param name="source"/>

	<!-- Process Mashup entities when true() (true() / false()) -->
	<xsl:variable name="INC_MASHUP" select="true()"/>
	<!-- Search in Mashup content when true() (true() / false()) -->
	<xsl:variable name="INC_MASH_CONTENT" select="true()"/>
	<!-- Display persisted properties values when true() (true() / false()) -->
	<xsl:variable name="SHOW_PROPS_VALUE" select="false()"/>
	<!-- Enable Class Digram when true() (true() / false()) -->
	<xsl:variable name="ENABLE_UML" select="true()"/>
	
	<xsl:template match="/">
		<xsl:if test="$source = 'fromhtml'">
			<xsl:apply-templates select="Entities"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Entities">
		<div id="twx-model" class="main">
			<div class="header">
				<xsl:call-template name="html_header_comp"/>
			</div>
			<div class="body">
				<xsl:apply-templates select="Things"/>
				<xsl:apply-templates select="ThingTemplates"/>
				<xsl:apply-templates select="ThingShapes"/>
				<xsl:apply-templates select="DataShapes"/>
				<xsl:if test="$INC_MASHUP">
					<xsl:apply-templates select="Mashups"/>
				</xsl:if>
				<xsl:apply-templates select="ExtensionPackages"/>
				<xsl:apply-templates select="Resources"/>
				<xsl:apply-templates select="Subsystems"/>
			</div>
		</div>
		<xsl:call-template name="html_comps_init"/>
	</xsl:template>

	<xsl:template match="EventDefinitions|ImplementedShapes|Subscriptions|PropertyDefinitions|ServiceImplementations|ServiceDefinitions|FieldDefinitions">
		<xsl:param name="entity_fullname"/>
		<xsl:if test="*">
			<ul class="flat">
				<xsl:apply-templates mode="list">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:apply-templates>
			</ul> 
		</xsl:if>
	</xsl:template>

	<xsl:template match="PropertyBindings|RemotePropertyBindings|RemoteServiceBindings">
		<xsl:param name="entity_fullname"/>
		<xsl:if test="*">
			<h4>
				<xsl:value-of select="name()"/>
			</h4>
			<ul class="flat">
				<xsl:apply-templates mode="list">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:apply-templates>
			</ul> 
		</xsl:if>
	</xsl:template>

	<xsl:template match="ThingProperties">

		<xsl:if test="*">
			<h4>
				<xsl:text>PersistedPropertyValues</xsl:text>
			</h4>
			<ul class="flat">
				<xsl:for-each select="*">
					<li class="{$ITEM_CLS} truncate dot" id="{generate-id()}" data-name="{name()}" data-type="PropertyValue">
						<xsl:call-template name="ui_property_value"/>
					</li>
				</xsl:for-each>
			</ul> 
		</xsl:if>
	</xsl:template>

	<xsl:template match="EventDefinition" mode="list">

		<li class="{$ITEM_CLS} dash" id="{generate-id()}" data-name="{@name}" data-type="{name()}">
			<xsl:apply-templates select="."/>
		</li>
	</xsl:template>

	<xsl:template match="EventDefinition">
		<xsl:call-template name="ui_event_def"/>
	</xsl:template>

	<xsl:template match="Subscription" mode="list">
		<xsl:param name="entity_fullname"/>
		
		<xsl:variable name="item_id" select="generate-id()"/>
		
		<li class="{$ITEM_CLS} dash" id="{$item_id}" data-name="{@eventName}" data-type="{name()}">
			<xsl:call-template name="ui_subscription_def"/><br/>
			<xsl:text>&#x22D9;</xsl:text>
			<xsl:apply-templates select="ServiceImplementation">
				<xsl:with-param name="item_id" select="$item_id"/>
				<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				<xsl:with-param name="service_name" select="''"/>
			</xsl:apply-templates>
		</li>
	</xsl:template>

	<xsl:template match="ImplementedShape" mode="list">
		
		<li class="plus">
			<xsl:call-template name="ui_thingshape_ref"/>
		</li>
	</xsl:template>

	<xsl:template match="PropertyDefinition" mode="list">

		<li class="{$ITEM_CLS} dash" id="{generate-id()}" data-name="{@name}" data-type="{name()}">
			<xsl:call-template name="ui_property_def"/>

			<xsl:variable name="property_name" select="@name"/>
			<xsl:variable name="property_remote_bind">
				<xsl:apply-templates select="../../../RemotePropertyBindings/RemotePropertyBinding[@name=$property_name]" mode="tooltip"/>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="$property_remote_bind != ''">
					<xsl:copy-of select="$property_remote_bind"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="property_local_bind">
						<xsl:apply-templates select="../../../PropertyBindings/PropertyBinding[@name=$property_name]"  mode="details"/>
					</xsl:variable>
					<xsl:if test="$property_local_bind != ''">
						<xsl:call-template name="ui_bind_tooltip">
							<xsl:with-param name="remote" select="false()"/>
							<xsl:with-param name="binding" select="$property_local_bind"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</li>
	</xsl:template>

	<xsl:template match="RemotePropertyBinding|RemoteServiceBinding|PropertyBinding" mode="list">

		<li class="{$ITEM_CLS} dot" id="{generate-id()}" data-name="{@name}" data-type="{name()}">
			<xsl:apply-templates select="."/>
		</li>
	</xsl:template>

	<xsl:template match="RemotePropertyBinding">
	
		<xsl:value-of select="@name"/>
		<xsl:call-template name="ui_property_remote_binding"/>
		<xsl:call-template name="ui_property_remote_binding_tooltip">
			<xsl:with-param name="full" select="false()"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="RemotePropertyBinding" mode="details">
		<xsl:call-template name="ui_property_remote_binding"/>
		<br/>
		<xsl:call-template name="ui_list_node_attrs"/>
	</xsl:template>

	<xsl:template match="RemotePropertyBinding" mode="tooltip">
		<xsl:call-template name="ui_property_remote_binding_tooltip">
			<xsl:with-param name="full" select="true()"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="PropertyBinding">
		<xsl:value-of select="@name"/>
		<xsl:call-template name="ui_property_local_binding"/>
	</xsl:template>

	<xsl:template match="PropertyBinding" mode="details">
		<xsl:call-template name="ui_property_local_binding"/>
		<br/>
		<xsl:call-template name="ui_list_node_attrs"/>
	</xsl:template>

	<xsl:template match="ServiceImplementation">
		<xsl:param name="item_id"/>
		<xsl:param name="entity_fullname"/>
		<xsl:param name="service_name"/>
		<xsl:param name="service_params"/>

		<xsl:call-template name="ui_service_impl">
			<xsl:with-param name="item_id" select="$item_id"/>
			<xsl:with-param name="service_name" select="$service_name"/>
		</xsl:call-template>

		<xsl:variable name="service_fullname" select="concat($entity_fullname, $SERVICE_SEP, @name)"/>
				
		<xsl:apply-templates select="ConfigurationTables/ConfigurationTable/Rows/Row/code|ConfigurationTables/ConfigurationTable/Rows/Row/sql">
			<xsl:with-param name="owner_id" select="$item_id"/>
			<xsl:with-param name="fullname" select="$service_fullname"/>
			<xsl:with-param name="params" select="$service_params"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="RemoteServiceBinding">
		<xsl:value-of select="@name"/>
		<xsl:call-template name="ui_service_binding"/>
	</xsl:template>

	<xsl:template match="RemoteServiceBinding" mode="details">
		<xsl:call-template name="ui_service_binding"/>
		<br/>
		<xsl:call-template name="ui_list_node_attrs"/>
	</xsl:template>

	<xsl:template match="ServiceDefinition">
		<xsl:param name="item_id"/>
		<xsl:param name="entity_fullname"/>

		<xsl:call-template name="ui_service_def"/>

		<xsl:variable name="params_def">
			<xsl:call-template name="ui_service_params"/>
		</xsl:variable>

		<xsl:variable name="service_name" select="@name"/>
		<xsl:variable name="service_remote_bind">
			<xsl:apply-templates select="../../../RemoteServiceBindings/RemoteServiceBinding[@name=$service_name]" mode="details"/>
		</xsl:variable>

		<span class="{$MORE_CLS}">
			<xsl:call-template name="ui_whereused">
				<xsl:with-param name="keyword" select="$service_name"/>
			</xsl:call-template>

			<xsl:choose>
				<xsl:when test="$service_remote_bind != ''">
					<xsl:call-template name="ui_bind_tooltip">
						<xsl:with-param name="remote" select="true()"/>
						<xsl:with-param name="binding" select="$service_remote_bind"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="service_impl">
						<xsl:apply-templates select="../../ServiceImplementations/ServiceImplementation[@name=$service_name]">
							<xsl:with-param name="item_id" select="$item_id"/>
							<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
							<xsl:with-param name="service_name" select="$service_name"/>
							<xsl:with-param name="service_params" select="$params_def"/>
						</xsl:apply-templates>
					</xsl:variable>

					<xsl:choose>
						<xsl:when test="$service_impl = ''">
							<span class="binding-tt">&#x26AF;</span>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="$service_impl"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</span>
		<xsl:call-template name="ui_params_tooltip">
			<xsl:with-param name="params_def" select="$params_def"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="ServiceDefinition" mode="list">
		<xsl:param name="entity_fullname"/>

		<xsl:variable name="item_id" select="generate-id()"/>
		
		<li class="{$ITEM_CLS} dash" id="{$item_id}" data-name="{@name}" data-type="{name()}">
			<xsl:apply-templates select=".">
				<xsl:with-param name="item_id" select="$item_id"/>
				<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
			</xsl:apply-templates>
		</li>		
	</xsl:template>

	<xsl:template match="code|sql|mashupContent">
		<xsl:param name="owner_id"/>
		<xsl:param name="fullname"/>
		<xsl:param name="params"/>

		<xsl:call-template name="ui_code">
			<xsl:with-param name="owner_id" select="$owner_id"/>
			<xsl:with-param name="fullname" select="$fullname"/>
			<xsl:with-param name="params" select="$params"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="FieldDefinition" mode="list">
		<li>
			<xsl:call-template name="ui_field_def"/>
		</li>
	</xsl:template>

	<xsl:template match="Things|ThingTemplates|ThingShapes">
		<h2 id="{name()}">
			<xsl:value-of select="name()"/>
		</h2>
		<table border="1">
			<tr>
				<th>Name</th>
				<th>ThingTemplate + ThingShapes</th>
				<th>Properties</th>
				<th>Services</th>
				<th>Events</th>
				<th>Subscriptions</th>
			</tr>
			<xsl:apply-templates select="Thing|ThingTemplate|ThingShape"/>
		</table>
	</xsl:template>

	<xsl:template match="Thing">
	
		<xsl:variable name="entity_fullname"><xsl:call-template name="entity_fullname"/></xsl:variable>
		
		<tr class="{$ENTITY_CLS}" id="{generate-id()}" data-name="{@name}" data-type="{name()}">
			<td>
				<xsl:call-template name="ui_entity_def">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
					<xsl:with-param name="modeled" select="true()"/>
				</xsl:call-template>
				<xsl:call-template name="ui_entity_config"/>
			</td>
			<td>
				<xsl:call-template name="ui_template_ref">
					<xsl:with-param name="template_name" select="@thingTemplate"/>
				</xsl:call-template>
				<xsl:apply-templates select="ImplementedShapes"/>
			</td>
			<td>
				<xsl:apply-templates select="ThingShape/PropertyDefinitions"/>
				<xsl:apply-templates select="RemotePropertyBindings"/>
				<xsl:apply-templates select="PropertyBindings"/>

				<xsl:if test="$SHOW_PROPS_VALUE">				
					<xsl:apply-templates select="ThingProperties"/>
				</xsl:if>
			</td>
			<td>
				<xsl:apply-templates select="ThingShape/ServiceDefinitions">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:apply-templates>
				<!--xsl:apply-templates select="RemoteServiceBindings"/-->
			</td>
			<td>
				<xsl:apply-templates select="ThingShape/EventDefinitions"/>
			</td>
			<td>
				<xsl:apply-templates select="ThingShape/Subscriptions">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:apply-templates>
			</td>	
		</tr>
	</xsl:template>
	
	<xsl:template match="ThingTemplate">
	
		<xsl:variable name="entity_fullname"><xsl:call-template name="entity_fullname"/></xsl:variable>
		
		<tr class="{$ENTITY_CLS}" id="{generate-id()}" data-name="{@name}" data-type="{name()}">
			<td>
				<xsl:call-template name="ui_entity_def">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
					<xsl:with-param name="modeled" select="true()"/>
				</xsl:call-template>
				<xsl:call-template name="ui_entity_config"/>
			</td>
			<td>
				<xsl:call-template name="ui_template_ref">
					<xsl:with-param name="template_name" select="@baseThingTemplate"/>
				</xsl:call-template>
				<xsl:apply-templates select="ImplementedShapes"/>
			</td>
			<td>
				<xsl:apply-templates select="ThingShape/PropertyDefinitions"/>
				<xsl:apply-templates select="RemotePropertyBindings"/>
				<xsl:apply-templates select="PropertyBindings"/>
			</td>
			<td>
				<xsl:apply-templates select="ThingShape/ServiceDefinitions">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:apply-templates>
				<!--xsl:apply-templates select="RemoteServiceBindings"/-->
			</td>
			<td>
				<xsl:apply-templates select="ThingShape/EventDefinitions"/>
			</td>
			<td>
				<xsl:apply-templates select="ThingShape/Subscriptions">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:apply-templates>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="ThingShapes">
		<h2 id="{name()}">
			<xsl:value-of select="name()"/>
		</h2>
		<table border="1">
			<tr>
				<th>Name</th>
				<th>Properties</th>
				<th>Services</th>
				<th>Events</th>
				<th>Subscriptions</th>
			</tr>
			<xsl:apply-templates select="ThingShape"/>
		</table>
	</xsl:template>
	
	<xsl:template match="ThingShape">
	
		<xsl:variable name="entity_fullname"><xsl:call-template name="entity_fullname"/></xsl:variable>
	
		<tr class="{$ENTITY_CLS}" id="{generate-id()}" data-name="{@name}" data-type="{name()}">
			<td>
				<xsl:call-template name="ui_entity_def">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
					<xsl:with-param name="modeled" select="true()"/>
				</xsl:call-template>
				<xsl:call-template name="ui_entity_config"/>
			</td>
			<td>
				<xsl:apply-templates select="PropertyDefinitions"/>
				<!--xsl:apply-templates select="RemotePropertyBindings"/-->
				<!--xsl:apply-templates select="PropertyBindings"/-->
			</td>
			<td>
				<xsl:apply-templates select="ServiceDefinitions">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:apply-templates>
			</td>
			<td>
				<xsl:apply-templates select="EventDefinitions"/>
			</td>
			<td>
				<xsl:apply-templates select="Subscriptions">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:apply-templates>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="Mashups">
		<h2 id="{name()}">
			<xsl:value-of select="name()"/>
			<xsl:if test="$INC_MASH_CONTENT">
				<xsl:text> (with searchable content)</xsl:text>
			</xsl:if>
		</h2>
		<table border="1">
			<tr>
				<th width="500px">Name</th>
				<th>Type and Parameters</th>
			</tr>
			<xsl:apply-templates select="Mashup"/>
		</table>
	</xsl:template>
	
	<xsl:template match="DataShapes">
		<h2 id="{name()}">
			<xsl:value-of select="name()"/>
		</h2>
		<table border="1">
			<tr>
				<th>Name</th>
				<th>Fields</th>
			</tr>
			<xsl:apply-templates select="DataShape"/>
		</table>
	</xsl:template>
	
	<xsl:template match="DataShape">
	
		<xsl:variable name="entity_fullname"><xsl:call-template name="entity_fullname"/></xsl:variable>
	
		<tr class="{$ENTITY_CLS}" id="{generate-id()}" data-name="{@name}" data-type="{name()}">
			<td>
				<xsl:call-template name="ui_entity_def">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:call-template>
			</td>
			<td>
				<xsl:apply-templates select="FieldDefinitions"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="Mashups">
		<h2 id="{name()}">
			<xsl:value-of select="name()"/>
			<xsl:if test="$INC_MASH_CONTENT">
				<xsl:text> (with searchable content)</xsl:text>
			</xsl:if>
		</h2>
		<table border="1">
			<tr>
				<th width="500px">Name</th>
				<th>Type and Parameters</th>
			</tr>
			<xsl:apply-templates select="Mashup"/>
		</table>
	</xsl:template>
	
	<xsl:template match="Mashup">
	
		<xsl:variable name="entity_fullname"><xsl:call-template name="entity_fullname"/></xsl:variable>
		<xsl:variable name="entity_id" select="generate-id()"/>
		
		<tr id="{$entity_id}">
			<td>
				<xsl:call-template name="ui_entity_def">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:call-template>
			</td>
			<td>
				<xsl:call-template name="ui_mashup_def"/>

				<xsl:variable name="params_def">
					<xsl:call-template name="ui_params_def"/>
				</xsl:variable>

				<xsl:call-template name="ui_params_tooltip">
					<xsl:with-param name="params_def" select="$params_def"/>
				</xsl:call-template>

				<xsl:if test="$INC_MASH_CONTENT">
					<xsl:apply-templates select="mashupContent">
						<xsl:with-param name="owner_id" select="$entity_id"/>
						<xsl:with-param name="fullname" select="$entity_fullname"/>
						<xsl:with-param name="params" select="''"/>
					</xsl:apply-templates>
				</xsl:if>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="Resources|ExtensionPackages|Subsystems">
		<h2 id="{name()}">
			<xsl:value-of select="name()"/>
		</h2>
		<table border="1">
			<tr>
				<th width="500px">Name</th>
				<th>Info</th>
			</tr>
			<xsl:apply-templates select="Resource|ExtensionPackage|Subsystem"/>
		</table>
	</xsl:template>
	
	<xsl:template match="ExtensionPackage">
	
		<xsl:variable name="entity_fullname"><xsl:call-template name="entity_fullname"/></xsl:variable>

		<tr id="{$entity_fullname}">
			<td>
				<xsl:call-template name="ui_entity_def">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:call-template>
			</td>
			<td>
				<xsl:call-template name="ui_extension_def"/>
			</td>
		</tr>
	</xsl:template>
	
		<xsl:template match="Subsystem|Resource">
	
		<xsl:variable name="entity_fullname"><xsl:call-template name="entity_fullname"/></xsl:variable>
		
		<tr id="{$entity_fullname}">
			<td>
				<xsl:call-template name="ui_entity_def">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:call-template>
				<xsl:call-template name="ui_entity_config"/>
			</td>
			<td>
				<xsl:call-template name="ui_entity_desc"/>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>
