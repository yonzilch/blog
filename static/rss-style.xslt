<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:atom="http://www.w3.org/2005/Atom">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
<html>
	<head>
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		<meta name="referrer" content="unsafe-url" />
		<title><xsl:value-of select="/atom:feed/atom:title"/></title>
		<link rel="stylesheet" href="/water.min.css" />
	</head>
	<body>
		<h1><xsl:value-of select="/atom:feed/atom:title"/></h1>

		<p>
			<xsl:value-of select="/atom:feed/atom:subtitle"/>
		</p>

		<p>
			This is the Atom news feed for the 
			<a><xsl:attribute name="href">
				<xsl:value-of select="/atom:feed/atom:link[@rel='alternate']/@href | /atom:feed/atom:link[not(@rel)]/@href"/>
			</xsl:attribute>
			<xsl:value-of select="/atom:feed/atom:title"/></a>
			website.
		</p>

		<ul>
		<xsl:for-each select="/atom:feed/atom:entry">
			<li>
				<xsl:value-of select="atom:title" /> 
				(<xsl:value-of select="atom:updated" />)
			</li>
		</xsl:for-each>
		</ul>
		<p><xsl:value-of select="count(/atom:feed/atom:entry)"/> news items.</p>
		<p><small>Powered by <a href="https://www.feed.style/">Feed.Style</a></small></p>
	</body>
</html>
	</xsl:template>
</xsl:stylesheet>