<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:sg="http://www.sgmlguru.org/ns"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy" use-accumulators="#all"/>
    
    
    <xsl:include href="../../../common/xslt//functions.xsl"/>
    
    
    <xsl:template match="ulink">
        <xsl:message expand-text="yes">
            Converted {sg:get-xpath(.)} to refext and @url to @refloc
        </xsl:message>
        <refext refloc="{@url}">
            <xsl:apply-templates select="node()"/>
        </refext>
    </xsl:template>
    
</xsl:stylesheet>