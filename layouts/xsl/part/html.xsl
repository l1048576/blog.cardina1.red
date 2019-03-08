<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:html="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xsl html"
>
<!-- set output format -->
<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />

<xsl:template match="html:*">
	<xsl:element name="{local-name(.)}">
		<xsl:copy-of select="@*" />
		<xsl:apply-templates />
		<!-- About void elements, see <https://developer.mozilla.org/en-US/docs/Glossary/Empty_element>. -->
		<xsl:choose>
			<!-- Void elements should be self-closing tag. -->
			<xsl:when test="
				html:area |
				html:base |
				html:br |
				html:col |
				html:emded |
				html:hr |
				html:img |
				html:input |
				html:link |
				html:meta |
				html:param |
				html:source |
				html:track |
				html:wbr
				"></xsl:when>
			<!-- Non-void elements with child content cannot not be self-closing and no more things to do. -->
			<xsl:when test="html:*[node()]"></xsl:when>
			<!-- Non-void elements without child content should not be self-closing. -->
			<xsl:otherwise>
				<xsl:comment><xsl:text> </xsl:text></xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

</xsl:stylesheet>
