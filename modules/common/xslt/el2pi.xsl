<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:sg="http://www.sgmlguru.org/ns"
    exclude-result-prefixes="xs math sg"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy" use-accumulators="#all"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    
    <xsl:include href="./functions.xsl"/>
    
    
    <!-- Name of the module, e.g. 'ata' -->
    <xsl:param name="module" as="xs:string?"/>
    
    
    <xsl:variable name="path" select="'../../' || $module || '/'"/>
    
    <xsl:variable
        name="path-with-filename"
        select="if (doc-available($path || 'module.properties.local.xml'))
                then ($path || 'module.properties.local.xml')
                else ($path || 'module.properties.xml')"/>
    
    <xsl:variable
        name="inclusion-elements"
        select="tokenize(doc($path-with-filename)//inclusions/empty/@value, ' ')"
        as="xs:string*"/>
    
    
    <xsl:variable
        name="non-nested"
        select="$inclusion-elements"
        as="xs:string*"/>
    
    <xsl:template match="/">
        <xsl:message expand-text="yes">
            Module {$module}
        </xsl:message>
        <xsl:next-match/>
    </xsl:template>
    
    
    <!-- Non-nested -->
    <xsl:template match="*[name(.) = $non-nested]">
        <xsl:processing-instruction name="{name(.)}">
            <xsl:for-each select="@*">
                <xsl:value-of select="name(.) || '=&quot;' || . || '&quot;'"/>
                <xsl:value-of select="if (position() != last()) then (' ') else ()"/>
            </xsl:for-each>
        </xsl:processing-instruction>
        
        <xsl:message expand-text="yes">
            Convert non-nested element {sg:get-xpath(.)} to PI
        </xsl:message>
    </xsl:template>
    
</xsl:stylesheet>