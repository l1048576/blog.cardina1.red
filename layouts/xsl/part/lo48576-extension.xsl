<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="http://docbook.org/ns/docbook"
	xmlns:ds="https://www.cardina1.red/_ns/docbook/stylesheet"
	xmlns:le="https://www.cardina1.red/_ns/docbook/lo48576-extension"
	xmlns:les="https://www.cardina1.red/_ns/docbook/lo48576-extension/stylesheet"
	exclude-result-prefixes="xsl d ds le"
>
<!-- set output format -->
<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />

<xsl:template match="*" mode="les:attrs" />

<xsl:template match="les:*" mode="les:attrs">
	<xsl:apply-templates select="." mode="les:default-attrs" />
</xsl:template>

<xsl:template match="*" mode="les:default-attrs" />

<xsl:template match="les:*" mode="les:default-attrs">
	<xsl:if test="@xml:lang">
		<xsl:attribute name="xml:lang">
			<xsl:value-of select="@xml:lang" />
		</xsl:attribute>
		<xsl:attribute name="lang">
			<xsl:value-of select="@xml:lang" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<!-- Alternative: `d:date`. -->
<xsl:template match="le:time">
	<time>
		<xsl:apply-templates select="." mode="les:attrs" />
		<xsl:apply-templates />
	</time>
</xsl:template>

<xsl:template match="le:br">
	<br />
</xsl:template>

<xsl:template match="le:ruby">
	<ruby>
		<xsl:apply-templates select="." mode="les:attrs" />
		<xsl:apply-templates />
	</ruby>
</xsl:template>

<xsl:template match="le:rb">
	<rb>
		<xsl:apply-templates select="." mode="les:attrs" />
		<xsl:apply-templates />
	</rb>
</xsl:template>

<xsl:template match="le:rp">
	<rp>
		<xsl:apply-templates select="." mode="les:attrs" />
		<xsl:apply-templates />
	</rp>
</xsl:template>

<xsl:template match="le:rt">
	<rt>
		<xsl:apply-templates select="." mode="les:attrs" />
		<xsl:apply-templates />
	</rt>
</xsl:template>

<xsl:template match="le:rtc">
	<rtc>
		<xsl:apply-templates select="." mode="les:attrs" />
		<xsl:apply-templates />
	</rtc>
</xsl:template>

<!-- Alternative: `d:*[@revisionflag='added']`. -->
<xsl:template match="le:ins">
	<ins>
		<xsl:apply-templates select="." mode="les:attrs" />
		<xsl:apply-templates />
	</ins>
</xsl:template>

<!-- Alternative: `d:*[@revisionflag='deleted']`. -->
<xsl:template match="le:ins">
	<del>
		<xsl:apply-templates select="." mode="les:attrs" />
		<xsl:apply-templates />
	</del>
</xsl:template>

<xsl:template match="le:ins | le:del" mode="les:attrs">
	<xsl:apply-templates select="." mode="les:default-attrs" />
	<xsl:if test="@cite">
		<xsl:attribute name="cite">
			<xsl:value-of select="@cite" />
		</xsl:attribute>
	</xsl:if>
	<xsl:if test="@datetime">
		<xsl:attribute name="datetime">
			<xsl:value-of select="@datetime" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
