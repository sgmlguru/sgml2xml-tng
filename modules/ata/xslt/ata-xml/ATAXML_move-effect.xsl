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
    
    
    <xsl:template match="(table | tprereq)[title[following-sibling::effect]]">
        <xsl:message expand-text="yes">
            In {sg:get-xpath(.)}, moved effect element to first in model
        </xsl:message>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="effect"/>
            <xsl:apply-templates select="node()[not(self::effect)]"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="effect[effect and sbeff]">
        <xsl:message expand-text="yes">
            In {sg:get-xpath(.)}, move nested effect outside
        </xsl:message>
        <xsl:copy-of select="effect"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()[not(self::effect)]"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="sheet[effect] | graphic[effect and count(effect) = 1]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="effect"/>
            <xsl:apply-templates select="node()[not(self::effect)]"/>
        </xsl:copy>
    </xsl:template>
    
    
    
</xsl:stylesheet>