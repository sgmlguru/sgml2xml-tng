<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    exclude-result-prefixes="xs math"
    default-mode="doctype"
    version="3.0">
    
    <!-- This XSLT generates an SGML DOCTYPE declaration for the DTD defined in schemas/models.xml -->
    
    <xsl:output method="text"/>
    
    
    <!-- Name of the module, e.g. 'ata' -->
    <xsl:param name="module" as="xs:string?"/>
    
    <xsl:variable
        name="root"
        select="name(/*)"/>
    <xsl:variable name="path" select="'../../../' || $module || '/schemas/'"/>
    <xsl:variable
        name="path-with-filename"
        select="if (doc-available($path || 'models.xml'))
        then ($path || 'models.xml')
        else ()"/>
    
    <!-- DOCTYPE lookup for PUBLIC and SYSTEM IDs -->
    <xsl:variable
        name="doctype-lookup"
        select="doc($path-with-filename)"/>
    
    <!-- Mapped elements -->
    <xsl:variable
        name="maps"
        select="$doctype-lookup//doctype[matches($root, @root) and @target='sgml']/maps/map"
        as="element()*"/>
    
    <!-- Elements using entity-type attrs -->
    <xsl:variable
        name="ent-elements"
        select="$maps/@context => distinct-values()"
        as="xs:string*"/>
    
    <!-- NOTATION lookup for internal subset -->
    <!-- Note that the lookup should contain full notation entries for every NOTATION declaration that isn't in the DTD -->
    <xsl:variable
        name="notations"
        as="map(*)"
        select="map:merge((
        for $entry in $doctype-lookup//doctype[matches($root, @root) and @target='sgml']/notations/notation[@suffix != '' and @name != '']
        return map:entry($entry/@suffix, $entry/@name) 
        ))"/>
    
    <!-- Internal subset-only NOTATION names -->
    <xsl:variable
        name="internal-subset-notations"
        as="map(*)"
        select="map:merge(( 
        for $entry in $doctype-lookup//doctype[matches($root, @root) and @target='sgml']/notations/notation[@suffix != '' and @name != '']
        return map:entry($entry/@suffix, $entry/@name) 
        ))"/>
    
    <!-- Internal subset-only NOTATION declarations lookup -->
    <!-- Note that the lookup should contain full notation entries for every NOTATION declaration that isn't in the DTD -->
    <xsl:variable
        name="notation-declarations"
        as="map(*)"
        select="map:merge(( 
        for $entry in $doctype-lookup//doctype[matches($root, @root) and @target='sgml']/notations/notation[@suffix != '' and @public != '']
        return map:entry($entry/@suffix, $entry/@public)
        ))"/>
    
    
    <xsl:template match="/">
        
        <!-- Output only PUBLIC ID so receiver won't try to map the SYSTEM ID -->
        <xsl:variable
            name="doctype"
            select="'&lt;!DOCTYPE ' || $root || ' PUBLIC &quot;' ||
            ($doctype-lookup//doctype[matches($root, @root) and @target='sgml'])/publicid ||
                        '&quot; [&#x0a;'"/>
        
        <xsl:message expand-text="yes">
            Module {$module}
            Root {$root}
            Doctype {$doctype}
            Elements {$ent-elements => string-join(', ')}
        </xsl:message>
        
        <!-- This is the initial DOCTYPE, ending with the left square bracket and a space -->
        <xsl:value-of select="$doctype"/>
        
        <!-- Filter the required elements only once -->
        <xsl:variable
            name="target-nodes"
            select=".//*[name() = $ent-elements]"/>
        
        <!-- Entities -->
        <xsl:variable name="entities">
            <xsl:apply-templates select="$target-nodes" mode="entities"/>
        </xsl:variable>
        
        <!-- Notations -->
        <xsl:variable name="notations">
            <xsl:apply-templates select="$target-nodes" mode="notations"/>
        </xsl:variable>
        
        <xsl:value-of
            select="string-join(distinct-values(tokenize($entities, '&#x0a;')), '&#x0a;') ||
                    '&#x0a;' ||
                    string-join(distinct-values(tokenize($notations, '&#x0a;')), '&#x0a;')"/>
        
        <xsl:text>&#x0a;]&gt;</xsl:text>
    </xsl:template>
    
    
    <!-- Entity generation -->
    <xsl:template match="*" mode="entities">
        <xsl:variable name="current-element" select="name(.)"/>
        
        <!-- Generate internal subset by iterating through applicable attrs -->
        <xsl:variable name="internal-subset">
            <xsl:iterate select="@*[name() = $maps[@context = $current-element]/@target]">
                
                <!-- Get suffix -->
                <xsl:variable
                    name="name"
                    select="replace(., '^(.*)\.([a-zA-Z0-9]+)$','$1')"/>
                
                <!-- Get name sans suffix -->
                <xsl:variable
                    name="suffix"
                    select="replace(., '^(.*)\.([a-zA-Z0-9]+)$','$2')"/>
                
                <!-- Notation -->
                <xsl:variable
                    name="current-notation">
                    <xsl:choose>
                        <!-- The NOTATION is not in the SGML DTD but there is a known declaration -->
                        <xsl:when test="map:contains($internal-subset-notations, $suffix)">
                            <xsl:value-of select="map:get($internal-subset-notations, $suffix)"/>
                        </xsl:when>
                        <!-- The NOTATION is in the SGML DTD -->
                        <xsl:when test="map:contains($notations, $suffix)">
                            <xsl:value-of select="map:get($notations, $suffix)"/>
                        </xsl:when>
                        <!-- No known NOTATION declaration so we use an upper-case NDATA value -->
                        <xsl:otherwise>
                            <xsl:value-of select="upper-case($suffix)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:text>&lt;!ENTITY </xsl:text>
                <xsl:value-of select="$name"/>
                <xsl:text> SYSTEM &quot;</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>&quot; NDATA </xsl:text>
                <xsl:value-of select="$current-notation"/>
                <xsl:text>&gt;&#x0a;</xsl:text>
            </xsl:iterate>
        </xsl:variable>
        
        
        <xsl:value-of select="$internal-subset"/>
    </xsl:template>
    
    
    <!-- Notation generation -->
    <xsl:template match="*" mode="notations">
        <xsl:variable name="current-element" select="name(.)"/>
        
        <!-- Generate internal subset by iterating through applicable attrs -->
        <xsl:variable name="internal-subset">
            <xsl:iterate select="@*[name() = $maps[@context = $current-element]/@target]">
                <!-- Get name -->
                <xsl:variable
                    name="name"
                    select="replace(., '^(.*)\.([a-zA-Z0-9]+)$','$1')"/>
                
                <!-- Get suffix -->
                <xsl:variable
                    name="suffix"
                    select="replace(., '^(.*)\.([a-zA-Z0-9]+)$','$2')"/>
                
                <xsl:variable
                    name="current-notation">
                    <xsl:choose>
                        <!-- The NOTATION is not in the SGML DTD but there is a known declaration -->
                        <xsl:when test="map:contains($internal-subset-notations, $suffix)">
                            <xsl:value-of select="map:get($internal-subset-notations, $suffix)"/>
                        </xsl:when>
                        <!-- The NOTATION is in the SGML DTD -->
                        <xsl:when test="map:contains($notations, $suffix)">
                            <xsl:value-of select="map:get($notations, $suffix)"/>
                        </xsl:when>
                        <!-- No known NOTATION declaration so we use an upper-case NDATA value -->
                        <xsl:otherwise>
                            <xsl:value-of select="upper-case($suffix)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- Output a NOTATION declaration, if the SGML does not have one -->
                <!-- The lookup should only have one if the DTD doesn't -->
                <xsl:if test="exists(map:get($notation-declarations, $suffix))">
                    <xsl:text>&lt;!NOTATION </xsl:text>
                    <xsl:value-of select="$current-notation"/>
                    <xsl:text> PUBLIC &quot;</xsl:text>
                    <xsl:value-of select="map:get($notation-declarations, $suffix)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:text>&gt;&#x0a;</xsl:text>
                </xsl:if>
            </xsl:iterate>
        </xsl:variable>
        
        
        <xsl:value-of select="$internal-subset"/>
    </xsl:template>
    
    
</xsl:stylesheet>