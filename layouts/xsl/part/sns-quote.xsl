<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:mml="http://www.w3.org/1998/Math/MathML"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:xl="http://www.w3.org/1999/xlink"
	xmlns:eh="https://www.cardina1.red/_ns/xml/easy-html/2017-0809"
	xmlns:snsq="https://www.cardina1.red/_ns/xml/sns-quote/2017-1018"
	exclude-result-prefixes="xsl html mml svg xl eh snsq"
>
<!-- set output format -->
<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />

<xsl:template match="*" select="." mode="easy-html-data-attr">
	<xsl:if test="ancestor-or-self::eh:* | ancestor-or-self::snsq:*">
		<xsl:attribute name="data-lo48576-easy-html">
			<xsl:value-of select="concat('{', namespace-uri(), '}', local-name())" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:template name="optional-anchor">
	<xsl:param name="href" />
	<xsl:param name="attrs" />
	<xsl:param name="body" />
	<xsl:choose>
		<xsl:when test="$href">
			<xsl:element name="a">
				<xsl:attribute name="href">
					<xsl:value-of select="$href" />
				</xsl:attribute>
				<xsl:copy-of select="$attrs" />
				<xsl:copy-of select="$body" />
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="$body" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Quotes. -->

<xsl:template match="snsq:sns-quotes[@mode='normal'] | snsq:sns-quotes[not(@mode)]">
	<div class="sns-quote__collection sns-quote__collection-normal">
		<xsl:apply-templates select="." mode="easy-html-data-attr" />
		<xsl:for-each select="snsq:sns-quote">
			<xsl:call-template name="sns-quote__quote-normal" />
		</xsl:for-each>
	</div>
</xsl:template>

<xsl:template match="snsq:sns-quotes[@mode='tiny']">
	<div class="sns-quote__collection sns-quote__collection-iny">
		<xsl:apply-templates select="." mode="easy-html-data-attr" />
		<xsl:for-each select="snsq:sns-quote">
			<xsl:call-template name="sns-quote__quote-tiny" />
		</xsl:for-each>
	</div>
</xsl:template>

<xsl:template match="snsq:sns-quote[@mode='normal'] | snsq:sns-quote[not(@mode)]">
	<xsl:call-template name="sns-quote__quote-normal" />
</xsl:template>

<xsl:template match="snsq:sns-quote[@mode='tiny']">
	<xsl:call-template name="sns-quote__quote-tiny" />
</xsl:template>

<xsl:template name="sns-quote__quote-normal">
	<xsl:element name="blockquote">
		<xsl:attribute name="class">
			<xsl:text>sns-quote sns-quote__note-normal</xsl:text>
			<xsl:if test="@class">
				<xsl:value-of select="concat(' ', @class)" /></xsl:if>
		</xsl:attribute>
		<xsl:apply-templates select="." mode="easy-html-data-attr" />

		<header class="sns-quote__header-wrapper">
			<xsl:apply-templates select="." mode="easy-html-data-attr" />
			<xsl:apply-templates select="snsq:identity/snsq:icon" mode="sns-quote__header" />
			<div class="sns-quote__header">
			<xsl:apply-templates select="." mode="easy-html-data-attr" />
				<xsl:apply-templates select="snsq:identity" mode="sns-quote__header" />
				<xsl:apply-templates select="snsq:meta/snsq:timestamp" mode="sns-quote__header" />
			</div>
		</header>
		<xsl:apply-templates select="snsq:content" mode="sns-quote__quote-root" />
		<xsl:apply-templates select="snsq:attachments" mode="sns-quote__quote-root" />
		<xsl:call-template name="sns-quote__footer" />
	</xsl:element>
</xsl:template>

<xsl:template name="sns-quote__quote-tiny">
	<xsl:element name="blockquote">
		<xsl:attribute name="class">
			<xsl:text>sns-quote sns-quote__note-tiny</xsl:text>
			<xsl:if test="@class">
				<xsl:value-of select="concat(' ', @class)" /></xsl:if>
		</xsl:attribute>
		<xsl:if test="@url">
			<xsl:attribute name="cite">
				<xsl:value-of select="@url" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="." mode="easy-html-data-attr" />

		<xsl:apply-templates select="snsq:identity/snsq:icon" mode="sns-quote__header" />
		<div class="sns-quote__main-block">
			<xsl:apply-templates select="." mode="easy-html-data-attr" />
			<header class="sns-quote__header-wrapper">
				<xsl:apply-templates select="." mode="easy-html-data-attr" />
				<div class="sns-quote__header">
					<xsl:apply-templates select="." mode="easy-html-data-attr" />
					<xsl:apply-templates select="snsq:identity" mode="sns-quote__header" />
					<xsl:apply-templates select="snsq:meta/snsq:timestamp" mode="sns-quote__header" />
				</div>
			</header>
			<xsl:apply-templates select="snsq:content" mode="sns-quote__quote-root" />
			<xsl:apply-templates select="snsq:attachments" mode="sns-quote__quote-root" />
			<xsl:call-template name="sns-quote__footer" />
		</div>
	</xsl:element>
</xsl:template>

<xsl:template match="snsq:icon" mode="sns-quote__header">
	<div class="sns-quote__icon-wrapper">
		<xsl:apply-templates select="." mode="easy-html-data-attr" />
		<xsl:if test="@src">
			<xsl:call-template name="optional-anchor">
				<xsl:with-param name="href" select="../@url" />
				<xsl:with-param name="body">
					<img class="sns-quote__icon" src="{@src}" alt="{../@snsq:nickname}" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</div>
</xsl:template>

<xsl:template match="snsq:identity" mode="sns-quote__header">
	<div class="sns-quote__user-info">
		<xsl:apply-templates select="." mode="easy-html-data-attr" />
		<div class="sns-quote__screen-name">
			<xsl:apply-templates select="." mode="easy-html-data-attr" />
			<bdi>
				<xsl:apply-templates select="." mode="easy-html-data-attr" />
				<xsl:call-template name="optional-anchor">
					<xsl:with-param name="href" select="@url" />
					<xsl:with-param name="body">
						<xsl:apply-templates select="snsq:screen-name/node()" />
					</xsl:with-param>
				</xsl:call-template>
			</bdi>
		</div>
		<div class="sns-quote__identity">
			<xsl:apply-templates select="." mode="easy-html-data-attr" />
			<xsl:call-template name="optional-anchor">
				<xsl:with-param name="href" select="@url" />
				<xsl:with-param name="body">
					<span class="service">
						<xsl:apply-templates select="." mode="easy-html-data-attr" />
						<bdi>
							<xsl:apply-templates select="." mode="easy-html-data-attr" />
							<xsl:apply-templates select="snsq:service/node()" />
						</bdi>
					</span>:
					<span class="nickname">
						<xsl:apply-templates select="." mode="easy-html-data-attr" />
						<bdi>
							<xsl:apply-templates select="." mode="easy-html-data-attr" />
							<xsl:value-of select="snsq:nickname" />
						</bdi>
					</span>
				</xsl:with-param>
			</xsl:call-template>
		</div>
	</div>
</xsl:template>

<xsl:template match="snsq:timestamp" mode="sns-quote__header">
	<div class="sns-quote__timestamp">
		<xsl:apply-templates select="." mode="easy-html-data-attr" />
		<bdi>
			<xsl:apply-templates select="." mode="easy-html-data-attr" />
			<xsl:call-template name="optional-anchor">
				<xsl:with-param name="href" select="../../@url" />
				<xsl:with-param name="body">
					<xsl:element name="time">
						<xsl:if test="@datetime">
							<xsl:attribute name="datetime">
								<xsl:value-of select="@datetime" />
							</xsl:attribute>
						</xsl:if>
						<xsl:apply-templates select="node()" />
					</xsl:element>
				</xsl:with-param>
			</xsl:call-template>
		</bdi>
	</div>
</xsl:template>

<xsl:template match="snsq:content" mode="sns-quote__quote-root">
	<div class="sns-quote__content">
		<xsl:apply-templates select="." mode="easy-html-data-attr" />
		<xsl:apply-templates select="node()" />
	</div>
</xsl:template>

<xsl:template match="snsq:attachments[count(snsq:*) = 0]" mode="sns-quote__quote-root" />

<xsl:template match="snsq:attachments" mode="sns-quote__quote-root">
	<div class="sns-quote__attachments">
		<xsl:apply-templates select="." mode="easy-html-data-attr" />
		attachments:
		<div class="sns-quote__attachments-outer-box">
			<xsl:apply-templates select="." mode="easy-html-data-attr" />
			<xsl:for-each select="snsq:*">
				<div class="sns-quote__attachment-inner-box">
					<xsl:apply-templates select="." mode="easy-html-data-attr" />
					<xsl:apply-templates select="." mode="sns-quote__attachment" />
				</div>
			</xsl:for-each>
		</div>
	</div>
</xsl:template>

<xsl:template match="snsq:image" mode="sns-quote__attachment">
	<xsl:call-template name="optional-anchor">
		<xsl:with-param name="href">
			<xsl:choose>
				<xsl:when test="@thumb-src">
					<xsl:value-of select="@thumb-src" />
				</xsl:when>
				<xsl:when test="@src">
					<xsl:value-of select="@src" />
				</xsl:when>
				<xsl:when test="@orig-src">
					<xsl:value-of select="@orig-src" />
				</xsl:when>
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name="body">
			<div class="sns-quote__attachment-medium-wrapper">
				<xsl:apply-templates select="." mode="easy-html-data-attr" />
				<xsl:element name="img">
					<xsl:attribute name="class">
						sns-quote__attachment sns-quote__image
						<xsl:if test="@cw = 'true'">
							sns-quote__cw
						</xsl:if>
					</xsl:attribute>
					<xsl:attribute name="src">
						<xsl:choose>
							<xsl:when test="@src">
								<xsl:value-of select="@src" />
							</xsl:when>
							<xsl:when test="@orig-src">
								<xsl:value-of select="@orig-src" />
							</xsl:when>
							<xsl:when test="@thumb-src">
								<xsl:value-of select="@thumb-src" />
							</xsl:when>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="alt"><xsl:value-of select="@alt" /></xsl:attribute>
					<xsl:apply-templates select="." mode="easy-html-data-attr" />
				</xsl:element>
			</div>
		</xsl:with-param>
	</xsl:call-template>
	<div>
		<xsl:apply-templates select="." mode="easy-html-data-attr" />
		<ul>
			<xsl:apply-templates select="." mode="easy-html-data-attr" />
			<xsl:if test="@thumb-src">
				<li>
					<xsl:apply-templates select="." mode="easy-html-data-attr" />
					<a href="{@thumb-src}">link to the thumbnail</a>
				</li>
			</xsl:if>
			<xsl:if test="@src">
				<li>
					<xsl:apply-templates select="." mode="easy-html-data-attr" />
					<a href="{@src}">link to original file</a>
				</li>
			</xsl:if>
			<xsl:if test="@orig-src">
				<li>
					<xsl:apply-templates select="." mode="easy-html-data-attr" />
					<a href="{@orig-src}">link to original source</a>
				</li>
			</xsl:if>
			<xsl:if test="@orig-page">
				<li>
					<xsl:apply-templates select="." mode="easy-html-data-attr" />
					<a href="{@orig-page}">link to original page</a>
				</li>
			</xsl:if>
		</ul>
	</div>
</xsl:template>

<xsl:template name="sns-quote__footer">
	<xsl:if test="
			snsq:footer/node() |
			snsq:meta/snsq:reftime[@enabled = 'true'] |
			snsq:meta/snsq:in-reply-to[not(@enabled = 'false')]">
		<footer class="sns-quote__footer">
			<xsl:apply-templates select="." mode="easy-html-data-attr" />
			<xsl:apply-templates select="snsq:meta/snsq:reftime" mode="sns-quote__footer" />
			<xsl:apply-templates select="snsq:meta/snsq:in-reply-to" mode="sns-quote__footer" />
			<xsl:apply-templates select="snsq:footer/node()" />
		</footer>
	</xsl:if>
</xsl:template>

<!-- default disabled. -->
<xsl:template match="snsq:reftime[@enabled = 'true']" mode="sns-quote__footer">
	<div class="sns-quote__reftime">
		<xsl:apply-templates select="." mode="easy-html-data-attr" />
		<small>
			<xsl:apply-templates select="." mode="easy-html-data-attr" />
			参照日時:
			<bdi>
				<xsl:apply-templates select="." mode="easy-html-data-attr" />
				<xsl:element name="time">
					<xsl:if test="@datetime">
						<xsl:attribute name="datetime">
							<xsl:value-of select="@datetime" />
						</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="." mode="easy-html-data-attr" />
					<xsl:apply-templates select="node()" />
				</xsl:element>
			</bdi>
		</small>
	</div>
</xsl:template>

<xsl:template match="snsq:reftime" mode="sns-quote__footer" />

<!-- default disabled. -->
<xsl:template match="snsq:in-reply-to[@enabled = 'false']" mode="sns-quote__footer" />

<xsl:template match="snsq:in-reply-to" mode="sns-quote__footer">
	<div class="sns-quote__in-reply-to">
		<xsl:apply-templates select="." mode="easy-html-data-attr" />
		<xsl:call-template name="optional-anchor">
			<xsl:with-param name="href" select="@url" />
			<xsl:with-param name="body">
				<xsl:choose>
					<xsl:when test="count(node())">
						<xsl:apply-templates select="node()" /> への返信
					</xsl:when>
					<xsl:when test="@url">
						<xsl:value-of select="@url" /> への返信
					</xsl:when>
					<xsl:otherwise>
						ある投稿への返信
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</div>
</xsl:template>

</xsl:stylesheet>
