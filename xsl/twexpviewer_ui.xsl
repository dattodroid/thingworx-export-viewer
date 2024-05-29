<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<!--
	Used by : twexpviewer.xsl
	Bug / suggestion : smainente@ptc.com
-->	
	<xsl:variable name="THINGSHAPE" select="'ThingShape'"/>
	<xsl:variable name="THING" select="'Thing'"/>
	<xsl:variable name="THINGTEMPLATE" select="'ThingTemplate'"/>
	<xsl:variable name="MASHUP" select="'Mashup'"/>
	<xsl:variable name="EXTENSION" select="'Extension'"/>

	<xsl:variable name="TYPE_SEP" select="'|'"/>
	<xsl:variable name="SERVICE_SEP" select="'::'"/>
	<xsl:variable name="PROP_SEP" select="'@'"/>
	<xsl:variable name="ITEM_SEP" select="'~'"/>

	<xsl:variable name="ME" select="'me'"/>

	<xsl:variable name="BASE_TEMPLATE_CLS" select="'_template'"/>
	<xsl:variable name="BASE_SHAPE_CLS" select="'_shape'"/>
	<xsl:variable name="ITEM_CLS" select="'_item'"/>
	<xsl:variable name="ENTITY_CLS" select="'_entity'"/>
	<xsl:variable name="SRV_PARAMS_CLS" select="'_params'"/>
	<xsl:variable name="PROP_TYPE_CLS" select="'_prop'"/>
	<xsl:variable name="CODE_CLS" select="'_code'"/>
	<xsl:variable name="MORE_CLS" select="'_more'"/>

<!-- ENTITIES -->
	
	<xsl:template name="entity_fullname">
			<xsl:value-of select="concat(name(), $TYPE_SEP, @name)"/>
	</xsl:template>
	
	<xsl:template name="ui_entity_desc">
			<xsl:value-of select="@description"/>
	</xsl:template>
	
	<xsl:template name="ui_entity_def">
		<xsl:param name="entity_fullname"/>
		<xsl:param name="modeled"/>
		
		<span>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="@aspect.isSystemObject = 'true'">entity_label i</xsl:when>
					<xsl:when test="@enabled != 'true'">entity_label s</xsl:when>
					<xsl:when test="@aspect.isExtension = 'true'">entity_label n</xsl:when>
					<xsl:otherwise>entity_label b</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="@name"/>
		</span>
		
		<span class="{$MORE_CLS}">
			<xsl:if test="@aspect.isExtension = 'true'">
				<span class="ext-tag">ext</span>
			</xsl:if>
			<xsl:call-template name="ui_whereused">
				<xsl:with-param name="keyword" select="@name"/>
			</xsl:call-template>
		</span>	
		<xsl:if test="$modeled">
			<xsl:call-template name="ui_details">
				<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
			</xsl:call-template>
			<xsl:if test="$ENABLE_UML">
				<xsl:call-template name="ui_uml">
					<xsl:with-param name="entity_fullname" select="$entity_fullname"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="ui_entity_config">
		<div class="entity-config">
			<xsl:if test="@valueStream != ''">
				<xsl:text>&#x21DD;</xsl:text><xsl:value-of select="@valueStream"/>
			</xsl:if>

			<xsl:if test="@effectiveThingPackage != '' or @className != ''">
				<span class="tooltip configs-tt">
					<xsl:text>&#x229E;</xsl:text>
					<span class="tooltiptext">
						<xsl:if test="@effectiveThingPackage != ''">
							<xsl:variable name="package_name" select="@effectiveThingPackage"/>
							<xsl:text>package : </xsl:text><xsl:value-of select="@effectiveThingPackage"/><br/>
							<xsl:text>packageClass : </xsl:text><xsl:value-of select="/Entities/ThingPackages/ThingPackage[@name=$package_name]/@className"/>
						</xsl:if>
						<xsl:if test="@className != ''">
							<xsl:text>class : </xsl:text><xsl:value-of select="@className"/><br/>
						</xsl:if>
					</span>
				</span>
			</xsl:if>

			<xsl:if test="ConfigurationTables/ConfigurationTable/Rows/Row/schedule != ''">
				<span class="tooltip configs-tt">
					<xsl:text>&#x1F4C5;</xsl:text>
					<span class="tooltiptext">
						<xsl:text>cron : </xsl:text><xsl:value-of select="ConfigurationTables/ConfigurationTable/Rows/Row/schedule"/><br/>
						<xsl:text>enabled : </xsl:text><xsl:value-of select="ConfigurationTables/ConfigurationTable/Rows/Row/enabled"/>
					</span>
				</span>
			</xsl:if>
			<xsl:if test="ConfigurationTables/ConfigurationTable/Rows/Row/updateRate != ''">
				<span class="tooltip configs-tt">
					<xsl:text>&#x23F0;</xsl:text>
					<span class="tooltiptext">
						<xsl:text>updateRate : </xsl:text><xsl:value-of select="ConfigurationTables/ConfigurationTable/Rows/Row/updateRate"/><br/>
						<xsl:text>enabled : </xsl:text><xsl:value-of select="ConfigurationTables/ConfigurationTable/Rows/Row/enabled"/>
					</span>
				</span>
			</xsl:if>

			<xsl:if test="ConfigurationTables/ConfigurationTable/Rows/Row/jDBCConnectionURL != ''">
				<span class="tooltip configs-tt">
					<xsl:text>&#13256;</xsl:text>
					<span class="tooltiptext">
						<xsl:text>jdbc driver : </xsl:text><xsl:value-of select="ConfigurationTables/ConfigurationTable/Rows/Row/jDBCDriverClass"/><br/>
						<xsl:text>jdbc url : </xsl:text><xsl:value-of select="ConfigurationTables/ConfigurationTable/Rows/Row/jDBCConnectionURL"/>
					</span>
				</span>
			</xsl:if>
		</div>
	</xsl:template>	

	<xsl:template name="ui_template_ref">
		<xsl:param name="template_name"/>
		
		<xsl:if test="$template_name !=''">
			<a class="{$BASE_TEMPLATE_CLS}" data-name="{$template_name}">
				<xsl:value-of select="$template_name"/>
			</a>
		</xsl:if> 
	</xsl:template>	

	<xsl:template name="ui_thingshape_ref">
		<a class="{$BASE_SHAPE_CLS} i" data-name="{@name}">
			<xsl:value-of select="@name"/>
		</a>
	</xsl:template>		

	<xsl:template name="ui_extension_def">
		<ul class="flat">
			<xsl:for-each select="@*">
				<xsl:if test=". !=''">
					<li><xsl:value-of select="name()" /> : <xsl:value-of select="." /></li>
				</xsl:if> 
			</xsl:for-each>
		</ul>
	</xsl:template>

	<xsl:template name="ui_mashup_def">
		<xsl:value-of select="@aspect.mashupType"/>
	</xsl:template>
	
<!-- PROPERTIES -->
	
	<xsl:template name="ui_property_def">
		<xsl:value-of select="@name"/><xsl:text> : </xsl:text><span class="{$PROP_TYPE_CLS}"><xsl:value-of select="@baseType"/></span>
		<xsl:text> &#x2504;</xsl:text><!-- - -->
		<xsl:if test="@aspect.isLogged = 'true'">
			<xsl:text> &#x24C1;,</xsl:text><!-- L -->
		</xsl:if>
		<xsl:if test="@aspect.isPersistent  = 'true'">
			<xsl:text> &#x24C5;,</xsl:text><!-- P -->
		</xsl:if>
		<xsl:call-template name="ui_aspects_tooltip"/>
	</xsl:template>
	
	<xsl:template name="ui_property_value">
		<xsl:value-of select="name()"/> = <xsl:value-of select="Value"/>
	</xsl:template>

	<xsl:template name="ui_property_remote_binding">
		<xsl:text> &#x2192; </xsl:text><!-- -> -->
		<xsl:choose>
			<xsl:when test="@aspect.tagAddress != ''">
				<xsl:text>&#x24BE; </xsl:text><!-- I for Industrial -->
				<xsl:value-of select="@aspect.tagAddress"/> (<xsl:value-of select="@aspect.industrialDataType"/>)
			</xsl:when>
			<xsl:when test="@sourceName != ''">
				<xsl:value-of select="@sourceName"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>?</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ui_property_local_binding">
		<xsl:text> &#x2192; </xsl:text><!-- -> -->
		<span class="_lbind">
			<xsl:value-of select="@sourceName"/><xsl:value-of select="$PROP_SEP"/><xsl:value-of select="@sourceThingName"/>
		</span>
	</xsl:template>

	<xsl:template name="ui_property_remote_binding_tooltip">
		<xsl:param name="full"/>
		<span class="tooltip binding-tt">
			<xsl:text>Remote </xsl:text>
			<xsl:choose>
				<xsl:when test="@pushType = 'NEVER'">
					<xsl:text>&#x21A6;</xsl:text> <!-- Pull only -->
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>&#x21E5;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>

			<span class="tooltiptext">
				<xsl:if test="$full">
					<xsl:call-template name="ui_property_remote_binding"/>
					<br/>
				</xsl:if>
				<xsl:call-template name="ui_list_node_attrs"/>
			</span>
		</span>
	</xsl:template>

<!-- SERVICES -->

	<xsl:template name="ui_service_def">

		<xsl:value-of select="@name"/>
		<xsl:if test="@aspect.isAsync = 'true'">
			<xsl:text>&#x24B6;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="ui_service_impl">
		<xsl:param name="item_id"/>
		<xsl:param name="service_name"/>
		
		<span class="impl-label">
			<xsl:if test="$service_name = ''">
				<xsl:value-of select="@name"/>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="@handlerName = 'Script' or @handlerName = 'SQLQuery' or @handlerName = 'SQLCommand'">
					<a href="javascript:TEV.showCode('{$item_id}');">
						{<xsl:value-of select="@handlerName"/>}
					</a>
				</xsl:when>
				<xsl:otherwise>
					{<xsl:value-of select="@handlerName"/>}
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>
	
	<xsl:template name="ui_service_params">
		<xsl:text>(</xsl:text><xsl:call-template name="ui_params_def"/><xsl:text>) : </xsl:text><xsl:value-of select="ResultType/@baseType"/>
	</xsl:template>
	
	<xsl:template name="ui_params_def">
		<xsl:for-each select="ParameterDefinitions/FieldDefinition">
			<xsl:value-of select="concat(@name, ' : ', @baseType)"/><xsl:if test="not(position() = last())"><xsl:text>, </xsl:text></xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="ui_params_tooltip">
		<xsl:param name="params_def"/>

		<xsl:if test="$params_def != ''">
			<span class="tooltip params-label">
				<xsl:text>(Params)</xsl:text><span class="tooltiptext {$SRV_PARAMS_CLS}"><xsl:value-of select="$params_def" /></span>
			</span>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="ui_service_binding">
		<xsl:text> &#x2192; </xsl:text><!-- -> -->
		<xsl:choose>
			<xsl:when test="@aspect.sourceName != ''">
				<xsl:value-of select="@sourceName"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>?</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
<!-- SUBSCRIPTIONS -->	
		
	<xsl:template name="ui_subscription_def">
		
		<span>
			<xsl:attribute name="class">
				<xsl:if test="@enabled = 'false'">s</xsl:if>
			</xsl:attribute>

			<xsl:value-of select="@eventName"/><xsl:text> </xsl:text>

			<xsl:if test="@sourceProperty != ''">
				<xsl:value-of select="@sourceProperty"/>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="@source != ''">
					<xsl:value-of select="$ITEM_SEP"/><xsl:value-of select="@source"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$PROP_SEP"/><xsl:value-of select="$ME"/>
				</xsl:otherwise>
			</xsl:choose>
		</span>	
	</xsl:template>		
	
<!-- EVENTS -->		

	<xsl:template name="ui_event_def">
		<xsl:value-of select="@name"/>
	</xsl:template>	
	
<!-- MISC -->

	<xsl:template name="ui_twx_version">
		<xsl:value-of select="@majorVersion"/>.<xsl:value-of select="@minorVersion"/>.<xsl:value-of select="@revision"/> (<xsl:value-of select="@build"/>) - <xsl:value-of select="@modelPersistenceProviderPackage"/>
	</xsl:template>
	
	<xsl:template name="ui_bind_tooltip">
		<xsl:param name="remote"/>
		<xsl:param name="binding"/>

		<span class="tooltip binding-tt">
			<xsl:choose>
				<xsl:when test="$remote">
					<xsl:text>Remote </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Local </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<span class="tooltiptext">
				<xsl:copy-of select="$binding"/>
			</span>
			<xsl:text>&#x26AF;</xsl:text>
		</span>
	</xsl:template>
	
	<xsl:template name="ui_aspects_tooltip">
		<span class="tooltip aspects-tt">
			<xsl:text>Aspects</xsl:text>
			<span class="tooltiptext">
				<xsl:for-each select="@*">
					<xsl:if test="starts-with(name(), 'aspect.')">
						<xsl:value-of select="name()" /> : <xsl:value-of select="." />
						<br/>
					</xsl:if> 
				</xsl:for-each>
			</span>
		</span>
	</xsl:template>
	
	<xsl:template name="ui_list_node_attrs">
		<xsl:for-each select="@*">
			<xsl:value-of select="name()" /> : <xsl:value-of select="." /><br/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="ui_whereused">
		<xsl:param name="keyword"/>
		<a class="action-label" title="Where Used ?" href="javascript:TEV.findRefs('{$keyword}');">&#xA60F;</a>
	</xsl:template>
	
	<xsl:template name="ui_details">
		<xsl:param name="entity_fullname"/>
		<a class="action-label" title="Entity details" href="javascript:TEV.showDetails('{$entity_fullname}');">&#x25F0;</a>
	</xsl:template>

	<xsl:template name="ui_uml">
		<xsl:param name="entity_fullname"/>
		<a class="action-label" title="Class Diagram - Parents" href="javascript:TEV.showPCD('{$entity_fullname}');">&#x2119;</a>
		<a class="action-label" title="Class Diagram - Descendents" href="javascript:TEV.showDCD('{$entity_fullname}');">&#x1D53B;</a>
	</xsl:template>
	
	<xsl:template name="ui_code">
		<xsl:param name="owner_id"/>
		<xsl:param name="fullname"/>
		<xsl:param name="params"/>

		<div data-id="{$owner_id}" data-name="{$fullname}" data-params="{$params}" style="display:none" class="{$CODE_CLS}">
			<pre><code><xsl:value-of select="."/></code></pre>
		</div>
	</xsl:template>	

	<xsl:template name="ui_field_def">
		<xsl:value-of select="@name"/><xsl:text> : </xsl:text><xsl:value-of select="@baseType"/><xsl:text> [</xsl:text><xsl:value-of select="@ordinal"/><xsl:text>]</xsl:text>
	</xsl:template>

<!-- HTML -->

	<xsl:template name="html_header_comp">
		<a href="#Things"><xsl:text>Things</xsl:text></a><xsl:text> | </xsl:text>
		<a href="#ThingTemplates"><xsl:text>ThingTemplates</xsl:text></a><xsl:text> | </xsl:text>
		<a href="#ThingShapes"><xsl:text>ThingShapes</xsl:text></a><xsl:text> | </xsl:text>
		<a href="#DataShapes"><xsl:text>DataShapes</xsl:text></a><xsl:text> | </xsl:text>
		<xsl:if test="$INC_MASHUP">
			<a href="#Mashups"><xsl:text>Mashups</xsl:text></a><xsl:text> | </xsl:text>
		</xsl:if>
		<a href="#ExtensionPackages"><xsl:text>ExtensionPackages</xsl:text></a><xsl:text> | </xsl:text>
		<a href="#Resources"><xsl:text>Resources</xsl:text></a><xsl:text> | </xsl:text>
		<a href="#Subsystems"><xsl:text>Subsystems</xsl:text></a><xsl:text> | </xsl:text>
		<xsl:call-template name="ui_twx_version"/>
		<xsl:call-template name="doc_main_help"/>
	</xsl:template>

	<xsl:template name="html_mc_comp">
		<template id="UIModelCheckDialog">
			<div class="comp-root tog-dialog mc-dialog">
				<div class="tog-tab mc-tab">
					<button class="check">Check Model</button>
					<xsl:call-template name="doc_mc_help"/>
				</div>
				<div class="tog-body mc-body">
					<div class="tog-results">
						<table class="tog-results-tbl"></table>
					</div>
					<div class="status"></div>
				</div>
			</div>
		</template>
	</xsl:template>

	<xsl:template name="html_mv_comp">
		<template id="UIDefinitionsDialog">
			<div class="comp-root tog-dialog mv-dialog">
				<div class="tog-tab mv-tab">
					<input type="text" size="30" class="search" placeholder="Search definitions" /><xsl:text> Search definitions</xsl:text>
					<xsl:call-template name="doc_mv_help"/>
				</div>
				<div class="tog-body mv-body">
					<div class="tog-results">
						<table class="tog-results-tbl"></table>
					</div>
					<div class="status"></div>
				</div>
			</div>
		</template>
	</xsl:template>

	<xsl:template name="html_wu_comp">
		<template id="UIReferencesDialog">
			<div class="comp-root tog-dialog wu-dialog">
				<div class="tog-tab wu-tab">
					<input type="text" size="30" class="search" placeholder="Search in code"/><xsl:text> Search in code </xsl:text>
					<input type="checkbox" class="comments" checked="true"/><xsl:text> Ignore comments</xsl:text>
					<xsl:call-template name="doc_wu_help"/>
				</div>
				<div class="tog-body wu-body">
					<div class="tog-results">
						<table class="tog-results-tbl"></table>
					</div>
					<div class="status">
						<button class="bcprev">&lt;</button>
						<button class="bcnext">&gt;</button>
						<span class="bc"></span>
					</div>
				</div>
			</div>
		</template>
	</xsl:template>

	<xsl:template name="html_code_comp">
		<template id="UICodeViewer">
			<div class="comp-root modal-overlay">
				<div class="modal-container" contextmenu="codemenu">
					<div class="modal-header"></div>
					<div class="modal-body"></div>
					<menu type="context" id="codemenu">
						<menuitem class="defs" label="Find Definitions" onclick="TEV.findDefs()">
						</menuitem>
						<menuitem class="refs" label="Find all References" onclick="TEV.findRefs()">
						</menuitem>
					</menu>
				</div>
			</div>
		</template>
	</xsl:template>

	<xsl:template name="html_uml_comp"><!-- nomnoml UML lib -->
		<template id="UIUmlViewer">
			<!-- nomnoml UML lib -->
			<div class="comp-root modal-overlay">
				<div class="modal-container">
					<div class="uml-body">
						<canvas class="uml-canvas"></canvas>
					</div>
				</div>
			</div>
		</template>
	</xsl:template>
		
	<xsl:template name="html_comps_init">
		<xsl:call-template name="html_code_comp"/>
		<xsl:if test="$ENABLE_UML">
			<xsl:call-template name="html_uml_comp"/>
		</xsl:if>
		<xsl:call-template name="html_wu_comp"/>
		<xsl:call-template name="html_mv_comp"/>
		<xsl:call-template name="html_mc_comp"/>
	</xsl:template>

</xsl:stylesheet>