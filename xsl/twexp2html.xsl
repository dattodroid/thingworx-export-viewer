<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="twexpviewer.xsl"/>
	<xsl:variable name="VERSION" select="'2.3.0'"/>

	<xsl:template match="/">
		<html>
			<head>
				<link rel="stylesheet" href="./css/twexpviewer.css"/>
				<link rel="stylesheet" href="./css/hjs/styles/zenburn.css"/>
				<script src="./js/hjs/highlight.pack.js"></script>
				<script src="./js/nomnoml/lib/lodash.min.js"></script>
				<script src="./js/nomnoml/lib/dagre.min.js"></script>
				<script src="./js/nomnoml/nomnoml.js"></script>
				<script src="./js/twexpviewer_ui.js"></script>
				<script src="./js/twexpviewer_model.js"></script>
				<script src="./js/twexpviewer_checks.js"></script>
				<script src="./js/twexpviewer_main.js"></script>
				<title><xsl:text>Thingworx Export Viewer </xsl:text><xsl:value-of select="$VERSION"/> </title>
			</head>
			<body onload="loadAll()">
				<xsl:apply-templates select="Entities"/>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>