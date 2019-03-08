<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="http://docbook.org/ns/docbook"
	xmlns:ds="https://www.cardina1.red/_ns/docbook/stylesheet"
	exclude-result-prefixes="xsl d ds"
>

<xsl:import href="../docbook/xsl/docbook.xsl" />

<!-- set output format -->
<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />

<!-- Custom role. -->
<xsl:template match="d:phrase[@role='strike']">
	<s>
		<xsl:apply-templates select="." mode="ds:attr-common" />
		<xsl:apply-templates select="." mode="ds:inner" />
	</s>
</xsl:template>

<!-- Customization of docbook stylesheet. -->
<xsl:template match="d:abbrev | d:acronym" mode="ds:attr-custom">
	<xsl:call-template name="ds:attr-custom" />
	<xsl:if test="@title">
		<xsl:attribute name="title">
			<xsl:value-of select="@title" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:template name="permalink">
	<xsl:param name="node" select="." />
	<xsl:param name="id" select="$node/@xml:id" />

	<xsl:variable name="normalized-id" select="normalize-space($id)" />
	<xsl:if test="$normalized-id != ''">
		<xsl:element name="a" namespace="{$ds:html-ns}">
			<xsl:attribute name="class">
				<xsl:text>permalink</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="href">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="$normalized-id" />
			</xsl:attribute>
			<xsl:comment><xsl:text> </xsl:text></xsl:comment>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template match="d:title" mode="ds:section-heading-inner">
	<xsl:apply-templates />
	<xsl:variable name="sect-id">
		<xsl:apply-templates select="." mode="ds:section-id" />
	</xsl:variable>
	<xsl:call-template name="permalink">
		<xsl:with-param name="id" select="$sect-id" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="d:term" mode="ds:inner">
	<xsl:apply-templates />
	<xsl:call-template name="permalink" />
</xsl:template>

<xsl:template match="d:programlisting" mode="ds:attr-class-value">
	<xsl:call-template name="ds:attr-class-value" />
	<!-- For syntax highlighting filter `colorize_syntax` of nanoc. -->
	<xsl:if test="@language">
		<xsl:text>language-</xsl:text>
		<xsl:value-of select="@language" />
	</xsl:if>
</xsl:template>

<xsl:template match="d:footnote[count(*) = 1][d:simpara]/*">
	<!-- Unwrap paragraph if it is the only content of a footnote. -->
	<xsl:apply-templates select="." mode="ds:inner" />
</xsl:template>

<xsl:template match="*" mode="ds:footnotes-title">
	<xsl:text>脚注</xsl:text>
</xsl:template>

<!-- TODO: Treat source URI of `d:blockquote`. -->

</xsl:stylesheet>
