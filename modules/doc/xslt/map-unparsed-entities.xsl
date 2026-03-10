<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0"
    default-mode="ENT">
    
    <!-- This adds the URLs of unparsed entities to the respective elements -->
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    
    <!-- ATA sheet -->
    <xsl:template match="sheet">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!-- Graphic reference -->
            <xsl:attribute
                name="href"
                select="tokenize(unparsed-entity-uri(@gnbr),'/')[last()]"/>
            <!-- Companion file -->
            <xsl:if test="@cfnbr">
                <xsl:attribute
                    name="cfhref"
                    select="tokenize(unparsed-entity-uri(@cfnbr),'/')[last()]"/>
            </xsl:if>
            
            <xsl:message expand-text="yes">
                Element {name(.)}, gnbr {@gnbr}
                href {tokenize(unparsed-entity-uri(@gnbr),'/')[last()]}
                {if (@cfnbr) then ('cfhref ' || @cfnbr) else ()}
            </xsl:message>
            
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- ATA grsymbol -->
    <xsl:template match="grsymbol">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute
                name="href"
                select="tokenize(unparsed-entity-uri(@gnbr),'/')[last()]"/>
            
            <xsl:message expand-text="yes">
                Element {name(.)}, gnbr {@gnbr}
                href {tokenize(unparsed-entity-uri(@gnbr),'/')[last()]}
            </xsl:message>
            
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- ATA refmedia -->
    <xsl:template match="refmedia">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute
                name="href"
                select="tokenize(unparsed-entity-uri(@mednbr),'/')[last()]"/>
            
            <xsl:message expand-text="yes">
                Element {name(.)}, mednbr {@mednbr}
                href {tokenize(unparsed-entity-uri(@mednbr),'/')[last()]}
            </xsl:message>
            
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- DOC Example XML DTD -->
    <xsl:template match="graphic[@name]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            
            <xsl:attribute
                name="href"
                select="tokenize(unparsed-entity-uri(@name),'/')[last()]"/>
            
            <xsl:message expand-text="yes">
                Element {name(.)}, name {@name}
                href {tokenize(unparsed-entity-uri(@name),'/')[last()]}
            </xsl:message>
            
            <xsl:apply-templates select="node()"/>
            
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>