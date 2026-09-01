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
    
    
    <xsl:template match="table">
        <xsl:variable name="attrs" select="(@tabstyle,@alt)" as="attribute()*"/>
        <xsl:message expand-text="yes">
            Remove {string-join(for $a in $attrs return name($a),' ')} from {sg:get-xpath(.)} 
        </xsl:message>
        <xsl:copy>
            <xsl:copy-of select="@* except $attrs"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tgroup">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()[not(self::spanspec)]"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="entry[@spanname]">
        <xsl:variable name="spanname" select="@spanname" as="xs:string"/>
        <xsl:variable name="spanrange" select="preceding::spanspec[@spanname = $spanname]/@*[name(.) != 'spanname']" as="attribute()*"/>
        <xsl:copy>
            <xsl:copy-of select="@* except @spanname"/>
            <xsl:copy-of select="$spanrange"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>