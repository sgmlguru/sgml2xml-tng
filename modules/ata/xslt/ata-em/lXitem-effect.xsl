<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:sg="http://www.sgmlguru.org/ns"
    exclude-result-prefixes="xs math sg"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy" use-accumulators="#all"/>
    
    
    <xsl:include href="../common/functions.xsl"/>
    
    
    <!-- Move effect elements first in model to before the start tag. 
         Move effect elements last in the model to after the end tag.
         Keep other effect elementss where they are -->
    <xsl:template match="(l1item | l2item | l3item | l4item | l5item | l6item | l7item)[effect]">
        
        <xsl:message expand-text="yes">
            Moving effect elements in {sg:get-xpath(.)} to before/after the start tag
        </xsl:message>
        
        <xsl:copy-of select="effect[not(preceding-sibling::*[name(.)!='effect'])]"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()[not(self::effect[not(preceding-sibling::*[name(.)!='effect'])]) and not(self::effect[not(following-sibling::*[name(.)!='effect'])])]"/>
        </xsl:copy>
        <xsl:copy-of select="effect[not(following-sibling::*[name(.)!='effect'])]"/>
    </xsl:template>
    
</xsl:stylesheet>