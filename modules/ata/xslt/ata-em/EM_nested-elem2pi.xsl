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
        name="pi-parents"
        select="('row', 'l1item', 'l2item', 'l3item', 'l4item', 'l5item', 'l6item', 'l7item')"
        as="xs:string*"/>
    
    
    <xsl:template match="*[effect]" priority="20">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            
            <xsl:variable name="sbeff-pair">
                <xsl:variable name="sbeffs">
                    <sbeffs>
                        <xsl:copy-of select=".//sbeff"/>
                    </sbeffs>
                </xsl:variable>
                
                <sbeffs>
                    <xsl:apply-templates select="$sbeffs//sbeff" mode="sbeff"/>
                </sbeffs>
            </xsl:variable>
            
            <!-- Symmetry (true means both SB start and end are in the model -->
            <xsl:variable
                name="symmetry"
                select="if (exists($sbeff-pair//sbeff[@pair='false'])) then ('false') else ('true')"/>
            
            <xsl:if test="$symmetry = 'false'">
                <xsl:message expand-text="yes">
                    Effectivity symmetry issue at {sg:get-xpath(.)},
                    converting to PIs
                </xsl:message>
            </xsl:if>
            
            <xsl:choose>
                <xsl:when test="self::note">
                    <xsl:apply-templates select="node()" mode="pi"/>
                </xsl:when>
            	<xsl:when test="name(.) = 'graphic' and count(effect) &gt; 1">
            		<xsl:apply-templates select="node()" mode="pi"/>
            	</xsl:when>
                <xsl:when test="name(.)=$pi-parents or $symmetry = 'false'">
                    <xsl:apply-templates select="node()" mode="pi"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="node()"/>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="effect[parent::note and position() = 1]" mode="pi" priority="10">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    
    <xsl:template match="effect[parent::note and preceding-sibling::*]" mode="pi" priority="10">
        <xsl:message expand-text="yes">
            Convert nested element {sg:get-xpath(.)} to PI
        </xsl:message>
        
        <xsl:processing-instruction name="{name(.)}">
            <xsl:for-each select="@*">
                <xsl:value-of select="name(.) || '=&quot;' || . || '&quot;'"/>
                <xsl:value-of select="if (position() != last()) then (' ') else ()"/>
            </xsl:for-each>
        </xsl:processing-instruction>
        
        <xsl:apply-templates select="node()" mode="pi"/>
    </xsl:template>
    
    
    <!-- Nested -->
    <xsl:template match="*[name(.) = $nested]" mode="pi">
        <xsl:message expand-text="yes">
            Convert nested element {sg:get-xpath(.)} to PI
        </xsl:message>
        
        <xsl:processing-instruction name="{name(.)}">
            <xsl:for-each select="@*">
                <xsl:value-of select="name(.) || '=&quot;' || . || '&quot;'"/>
                <xsl:value-of select="if (position() != last()) then (' ') else ()"/>
            </xsl:for-each>
        </xsl:processing-instruction>
        
        <xsl:apply-templates select="node()" mode="pi"/>
    </xsl:template>
    
    
    <xsl:template match="sbeff" mode="sbeff">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="pair">
                <xsl:choose>
                    <xsl:when test="@sbcond='END SB'">
                        <xsl:variable name="sbnbr" select="@sbnbr"/>
                        <xsl:value-of select="if (preceding-sibling::sbeff[@sbnbr=$sbnbr and @sbcond='SB']) then (true()) else (false())"/>
                    </xsl:when>
                    <xsl:when test="@sbcond='END PRE SB'">
                        <xsl:variable name="sbnbr" select="@sbnbr"/>
                        <xsl:value-of select="if (preceding-sibling::sbeff[@sbnbr=$sbnbr and @sbcond='PRE SB']) then (true()) else (false())"/>
                    </xsl:when>
                    <xsl:when test="@sbcond='SB'">
                        <xsl:variable name="sbnbr" select="@sbnbr"/>
                        <xsl:value-of select="if (following-sibling::sbeff[@sbnbr=$sbnbr and @sbcond='END SB']) then (true()) else (false())"/>
                    </xsl:when>
                    <xsl:when test="@sbcond='PRE SB'">
                        <xsl:variable name="sbnbr" select="@sbnbr"/>
                        <xsl:value-of select="if (following-sibling::sbeff[@sbnbr=$sbnbr and @sbcond='END PRE SB']) then (true()) else (false())"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="node()" mode="pi">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>