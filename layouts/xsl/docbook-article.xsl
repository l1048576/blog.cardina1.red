<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

<xsl:import href="part/html.xsl" />
<xsl:import href="part/docbook.xsl" />
<xsl:import href="part/sns-quote.xsl" />
<xsl:import href="part/lo48576-extension.xsl" />

<!-- set output format -->
<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />

<xsl:template match="/"><xsl:apply-templates /></xsl:template>

</xsl:stylesheet>
