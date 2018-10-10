<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="http://docbook.org/ns/docbook"
	xmlns:ds="https://www.cardina1.red/_ns/docbook/stylesheet"
	exclude-result-prefixes="xsl d ds"
>

<xsl:import href="layouts/xsl/docbook/xsl/docbook.xsl" />
<xsl:import href="layouts/xsl/easy-html.xsl" />

<!-- set output format -->
<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />

<xsl:template match="/"><xsl:apply-templates /></xsl:template>

<!-- Customization of docbook stylesheet. -->
<xsl:template match="d:abbrev | d:acronym" mode="ds:attr-custom">
	<xsl:call-template name="ds:attr-custom" />
	<xsl:if test="@title">
		<xsl:attribute name="title">
			<xsl:value-of select="@title" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:template match="d:date" mode="ds:attr-custom">
	<xsl:call-template name="ds:attr-custom" />
	<xsl:if test="@datetime">
		<xsl:attribute name="datetime">
			<xsl:value-of select="@datetime" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<!-- TODO: Treat source URI of `d:blockquote`. -->

</xsl:stylesheet>
