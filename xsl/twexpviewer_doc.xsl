<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<!--
	Used by : twexpviewer.xsl
	Bug / suggestion : smainente@ptc.com
-->	
	<xsl:template name="doc_main_help">
		<span class="help floatr"><b><xsl:text>?</xsl:text></b>
			<span class="helptext helpright">
				<table>
					<tr>
						<th colspan="2">Entities</th>
					</tr>
					<tr>
						<td>&#x25F0;</td>
						<td>Display entity inheritance tree and list inherited item definitions (properties, services, ...)<br/>
							Results are shown in the Model dialog (green tab)</td>
					</tr>
					<tr>
						<td>&#x2119;</td>
						<td>Show entity Inheritence Class Diagram</td>
					</tr>
					<tr>
						<td>&#x1D53B;</td>
						<td>Show entity Descendents Class Diagram</td>
					</tr>
					<tr>
						<td>&#x229E;</td>
						<td>Show entity package information (if available)</td>
					</tr>
					<tr>
						<td>&#x1F4C5;</td>
						<td>Show Scheduler configuration</td>
					</tr>
					<tr>
						<td>&#x23F0;</td>
						<td>Show Timer configuration</td>
					</tr>
					<tr>
						<td>&#13256;</td>
						<td>Show Database JDBC configuration</td>
					</tr>
					<tr>
						<td>&#x21DD;</td>
						<td>ValueStream assigned to the entity</td>
					</tr>
					<tr>
						<td><span class="ext-tag">ext</span></td>
						<td>Entity installed by an Extension</td>
					</tr>
					<tr>
						<th colspan="2">Properties</th>
					</tr>
					<tr>
						<td>&#x24C5;</td>
						<td>Persisted property</td>
					</tr>
					<tr>
						<td>&#x24C1;</td>
						<td>Logged property</td>
					</tr>
					<tr>
						<td><span class="binding-tt">Local &#x26AF;</span></td>
						<td>Local property binding</td>
					</tr>
					<tr>
						<td><span class="binding-tt">Remote &#x21A6;</span></td>
						<td>Remote property binding (PULL)</td>
					</tr>
					<tr>
						<td><span class="binding-tt">Remote &#x21E5;</span></td>
						<td>Remote property binding (PUSH)</td>
					</tr>
					<tr>
						<td>&#x24BE;</td>
						<td>Industrial Remote Binding (KEPWare)</td>
					</tr>	
					<tr>
						<th colspan="2">Services</th>
					</tr>
					<tr>
						<td><span class="binding-tt">&#x26AF;</span></td>
						<td>Remote Service Binding</td>
					</tr>
					<tr>
						<td>&#x24B6;</td>
						<td>Asynchronous service</td>
					</tr>
					<tr>
						<th colspan="2">Common</th>
					</tr>
					<tr>
						<td>&#xA60F;</td>
						<td>Search the qualified string in scripts and mashup contents.<br/>
							The search is plain text + case sensitve<br/>
							Results are shown in the WhereUsed dialog (blue tab).</td>
					</tr>
				</table>
			</span>
		</span>
	</xsl:template>

	<xsl:template name="doc_wu_help">
		<span class="help floatr"><xsl:text>?</xsl:text>
			<span class="helptext helptop">
				- Search in all the source codes available in the export (JS scripts, SQL, Mashup Contents)<br/>
				- Case sensitive, plain text search
			</span>
		</span>
	</xsl:template>


	<xsl:template name="doc_mc_help">
		<span class="help floatr"><xsl:text>?</xsl:text>
			<span class="helptext helptop">
				- Check the model for know issue or bad practices
			</span>
		</span>
	</xsl:template>

	<xsl:template name="doc_mv_help">
		<span class="help floatr"><xsl:text>?</xsl:text>
			<span class="helptext helptop">
				- Search all definitions (inheritance aware)<br/>
				- Case sensitive, plain text search<br/>
				<table>
					<tr>
						<th colspan="2">Results</th>
					</tr>
					<tr>
						<td>GetPropertyDiagnostics <b>@</b> SmaIndus <b>~</b> IndustrialThingShape</td>
						<td><b>GetPropertyDiagnostics</b> was found on <b>SmaIndus</b> and is locally defined on <b>IndustrialThingShape</b></td>
					</tr>
					<tr>
						<td>GetStreamEntriesWithData <b>~</b> Stream</td>
						<td><b>GetStreamEntriesWithData</b> was found and is defined on <b>Stream</b></td>
					</tr>

				</table>
			</span>
		</span>
	</xsl:template>

</xsl:stylesheet>