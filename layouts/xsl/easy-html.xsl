<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:mml="http://www.w3.org/1998/Math/MathML"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:xl="http://www.w3.org/1999/xlink"
	xmlns:eh="https://www.cardina1.red/_ns/xml/easy-html/2017-0309"
	exclude-result-prefixes="xsl html mml svg xl eh"
>
<!-- set output format -->
<!--<xsl:output method="html" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />-->
<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />


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
			ancestor::eh:article |
			ancestor::html:article |
			ancestor::eh:section |
			ancestor::html:section |
			ancestor::html:aside)" />
</xsl:template>

<xsl:template name="header-level">
	<xsl:param name="section_level">
		<xsl:call-template name="section-level" />
	</xsl:param>
	<xsl:choose>
		<xsl:when test="$section_level &lt;= 6"><xsl:value-of select="$section_level" /></xsl:when>
		<xsl:otherwise>6</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="footnotes">
	<xsl:variable name="article_id" select="generate-id(.)" />
	<xsl:if test="//eh:footnote[generate-id(ancestor::eh:article[1]) = $article_id]">
		<xsl:variable name="header_level">
			<xsl:call-template name="header-level" />
		</xsl:variable>
		<xsl:element name="aside">
			<xsl:attribute name="class">footnotes</xsl:attribute>
			<!-- 2 = uncounted `eh:article`(1) + parent `aside` (1) -->
			<xsl:element name="h{$header_level + 2}">
				<xsl:attribute name="id">footnote-label</xsl:attribute>
				<xsl:attribute name="class">footnote-label</xsl:attribute>
				<xsl:text>脚注</xsl:text>
			</xsl:element>
			<xsl:element name="ol">
				<xsl:attribute name="start">0</xsl:attribute>
					<xsl:for-each select="//eh:footnote[generate-id(ancestor::eh:article[1]) = $article_id]">
					<xsl:if test="not(@id)">
						<xsl:message terminate="yes">error: No `@id` found for `eh:footnote`.</xsl:message>
					</xsl:if>
					<xsl:variable name="footnote_index">
						<xsl:call-template name="footnote-index" />
					</xsl:variable>
					<xsl:element name="li">
						<xsl:attribute name="id"><xsl:value-of select="@id" /></xsl:attribute>
						<!--<xsl:attribute name="value"><xsl:value-of select="$footnote_index" /></xsl:attribute>-->
						<xsl:apply-templates select="node()" />
						<xsl:element name="a">
							<xsl:attribute name="href">#ref-<xsl:value-of select="@id" /></xsl:attribute>
							<xsl:text>&#x21B5;</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="footnote-index">
	<xsl:variable name="article_id" select="generate-id(ancestor::eh:article[1])" />
	<xsl:value-of select="count(preceding::eh:footnote[generate-id(ancestor::eh:article[1]) = $article_id])" />
</xsl:template>


<xsl:template match="text()"><xsl:value-of select="."/></xsl:template>

<xsl:template match="eh:*">
	<xsl:message terminate="yes">error: unknown element `eh:<xsl:value-of select="local-name(.)" />`.</xsl:message>
</xsl:template>

<xsl:template match="/"><xsl:apply-templates /></xsl:template>

<xsl:template match="eh:div">
	<xsl:element name="div">
		<xsl:call-template name="copy-attributes" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="eh:article">
	<xsl:element name="article">
		<xsl:call-template name="copy-attributes" />
		<xsl:apply-templates />
		<xsl:call-template name="footnotes" />
	</xsl:element>
</xsl:template>

<xsl:template match="html:*">
	<xsl:element name="{local-name(.)}">
		<xsl:call-template name="copy-attributes" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="eh:section">
	<xsl:element name="section">
		<xsl:call-template name="copy-attributes" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="eh:title">
	<xsl:variable name="header_level">
		<xsl:call-template name="header-level" />
	</xsl:variable>

	<xsl:element name="h{number($header_level)}">
		<xsl:call-template name="copy-attributes" />
		<xsl:value-of select="." /><xsl:call-template name="parent-permalink" />
	</xsl:element>
</xsl:template>

<xsl:template match="eh:footnote">
	<xsl:element name="a">
		<xsl:attribute name="id">ref-<xsl:value-of select="@id" /></xsl:attribute>
		<xsl:attribute name="href">#<xsl:value-of select="@id" /></xsl:attribute>
		<xsl:element name="sup">
			<xsl:attribute name="class">footnote-marker</xsl:attribute>
			<xsl:text>[</xsl:text>
			<xsl:call-template name="footnote-index" />
			<xsl:text>]</xsl:text>
		</xsl:element>
	</xsl:element>
</xsl:template>

<xsl:template match="eh:xref">
	<xsl:variable name="linkend" select="@linkend" />
	<xsl:variable name="target_node" select="/descendant-or-self::node()[@id=$linkend]" />
	<xsl:choose>
		<xsl:when test="count($target_node) &gt; 1">
			<xsl:message terminate="yes">error: Multiple nodes exist with `@id=<xsl:value-of select="$linkend" />`.</xsl:message>
		</xsl:when>
		<xsl:when test="count($target_node) &lt; 1">
			<xsl:message terminate="yes">error: No nodes exist with `@id=<xsl:value-of select="$linkend" />`.</xsl:message>
		</xsl:when>
	</xsl:choose>
	<xsl:element name="a">
		<xsl:attribute name="href">#<xsl:value-of select="$linkend" /></xsl:attribute>
		<xsl:choose>
			<xsl:when test="node()">
				<xsl:copy-of select="node()" />
			</xsl:when>
			<xsl:when test="$target_node[eh:title]">
				<xsl:apply-templates select="$target_node/eh:title/node()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">error: `eh:xref[@linkend='<xsl:value-of select="$linkend" />']` has no content but `node()[@id='<xsl:value-of select="$linkend" />']` has no `child::eh:title` element.
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<!-- Font Awesome icon. -->
<xsl:template match="eh:fa-icon">
	<xsl:if test="not(@icon)">
		<xsl:message terminate="yes">error: `eh:fa-icon` does not have an `@icon` attribute.</xsl:message>
	</xsl:if>
	<xsl:element name="i">
		<xsl:attribute name="class">
			<xsl:text>fa fa-</xsl:text>
			<xsl:value-of select="@icon" />
			<xsl:if test="@class">
				<xsl:value-of select="concat(' ', @class)" /></xsl:if>
		</xsl:attribute>
		<xsl:attribute name="aria-hidden">true</xsl:attribute>
	</xsl:element>
</xsl:template>

</xsl:stylesheet>
