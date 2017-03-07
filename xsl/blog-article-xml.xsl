<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:mml="http://www.w3.org/1998/Math/MathML"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:xl="http://www.w3.org/1999/xlink"
	xmlns:blog="https://blog.cardina1.red/2017-0307"
	exclude-result-prefixes="xsl html mml svg xl blog"
>
<!-- set output format -->
<xsl:output method="html" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />


<xsl:template name="copy-attributes">
	<xsl:for-each select="@*">
		<xsl:attribute name="{name(.)}">
			<xsl:value-of select="." />
		</xsl:attribute>
	</xsl:for-each>
</xsl:template>

<xsl:template name="parent-permalink">
	<xsl:if test="../@id">
		<xsl:element name="a">
			<xsl:attribute name="href"><xsl:value-of select="concat('#', ../@id)" /></xsl:attribute>
			<xsl:attribute name="class">permalink</xsl:attribute>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="section-level">
	<xsl:value-of select="count(
			ancestor::blog:article |
			ancestor::html:article |
			ancestor::blog:section |
			ancestor::html:section)" />
</xsl:template>

<xsl:template name="header-level">
	<xsl:param name="section_level">
		<xsl:call-template name="section-level" />
	</xsl:param>
	<xsl:choose>
		<xsl:when test="parent::html:aside">1</xsl:when>
		<xsl:when test="$section_level &lt;= 6"><xsl:value-of select="$section_level" /></xsl:when>
		<xsl:otherwise>6</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="text()"><xsl:value-of select="."/></xsl:template>

<xsl:template match="blog:*">
	<xsl:message terminate="yes">error: unknown element `blog:<xsl:value-of select="local-name(.)" />`.</xsl:message>
</xsl:template>

<xsl:template match="/blog:article">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:*">
	<xsl:element name="{local-name(.)}">
		<xsl:call-template name="copy-attributes" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="blog:section">
	<xsl:element name="section">
		<xsl:call-template name="copy-attributes" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="blog:title">
	<xsl:variable name="header_level">
		<xsl:call-template name="header-level" />
	</xsl:variable>

	<xsl:element name="h{number($header_level)}">
		<xsl:call-template name="copy-attributes" />
		<xsl:value-of select="." /><xsl:call-template name="parent-permalink" />
	</xsl:element>
</xsl:template>

</xsl:stylesheet>
