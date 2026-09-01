<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:sg="http://www.sgmlguru.org/ns"
    exclude-result-prefixes="xs math sg"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy" use-accumulators="#all"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    
    <xsl:include href="../../../common/xslt//functions.xsl"/>
    
    
    <xsl:variable
        name="nested"
        select="('effect', 'sbeff', 'coceff')"
        as="xs:string*"/>
    
    <xsl:variable
        name="prc"
        select="('prclist1', 'prclist2', 'prclist3', 'prclist4', 'prclist5', 'prclist6', 'prclist7', 'prcitem', 'prcitem1', 'prcitem2', 'prcitem3', 'prcitem4', 'prcitem5', 'prcitem6', 'prcitem7', 'subtask')"
        as="xs:string*"/>
    
    
    <xsl:template match="*[name(.)=$nested and (name(parent::*)=$prc or parent::effect[name(parent::*)=$prc])]" mode="#all">
        <xsl:message expand-text="yes">
            Convert nested element {sg:get-xpath(.)} in prcitem or prclist to PI
        </xsl:message>
        
        <xsl:processing-instruction name="{name(.)}">
            <xsl:for-each select="@*">
                <xsl:value-of select="name(.) || '=&quot;' || . || '&quot;'"/>
                <xsl:value-of select="if (position() != last()) then (' ') else ()"/>
            </xsl:for-each>
        </xsl:processing-instruction>
        
        <xsl:apply-templates select="node()" mode="pi"/>
    </xsl:template>
    
    
    <xsl:template match="node()" mode="pi">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>