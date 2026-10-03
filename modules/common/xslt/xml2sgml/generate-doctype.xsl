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
    
    <!-- This XSLT generates an SGML DOCTYPE declaration for ATA GEA DTDs -->
    
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
    <!-- TBA move to an external lookup -->
    <xsl:variable
        name="notations"
        as="map(*)"
        select="map {'tif' : 'ccitt4',
        'cgm' : 'cgm',
        'pdf' : 'pdf',
        'png' : 'png',
        'jpg' : 'jpeg',
        'wrl' : 'vrml',
        'mpg' : 'mpeg',
        'mp3' : 'mp3'}"/>
    
    <!-- Internal-subset NOTATIONs -->
    <!-- TBA move to an external lookup -->
    <xsl:variable
        name="internal-subset-notations"
        as="map(*)"
        select="map {'cortona3d' : 'CORTONA3D'}"/>
    
    <!-- Known internal subset-only NOTATION declarations -->
    <!-- TBA move to an external lookup -->
    <xsl:variable
        name="notation-declarations"
        as="map(*)"
        select="map {
        'cortona3d' : '-//CORTONA3D//NOTATION C3D Packages Encoding//EN'}"/>
    
    
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
                        <!-- The NOTATION is in the SGML DTD -->
                        <xsl:when test="exists(map:get($notations, $suffix))">
                            <xsl:value-of select="map:get($notations, $suffix)"/>
                        </xsl:when>
                        <!-- The NOTATION is not in the SGML DTD but there is a known declaration -->
                        <xsl:when test="exists(map:get($internal-subset-notations, $suffix))">
                            <xsl:value-of select="map:get($internal-subset-notations, $suffix)"/>
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
                        <!-- The NOTATION is in the SGML DTD -->
                        <xsl:when test="exists(map:get($notations, $suffix))">
                            <xsl:value-of select="map:get($notations, $suffix)"/>
                        </xsl:when>
                        <!-- The NOTATION is not in the SGML DTD but there is a known declaration -->
                        <xsl:when test="exists(map:get($internal-subset-notations, $suffix))">
                            <xsl:value-of select="map:get($internal-subset-notations, $suffix)"/>
                        </xsl:when>
                        <!-- No known NOTATION declaration so we use an upper-case NDATA value -->
                        <xsl:otherwise>
                            <xsl:value-of select="upper-case($suffix)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- Output a NOTATION declaration, if the SGML does not have one -->
                <xsl:if test="not(exists(map:get($notations, $suffix)))">
                    <xsl:text>&lt;!NOTATION </xsl:text>
                    <xsl:value-of select="$current-notation"/>
                    
                    <xsl:choose>
                        <!-- The NOTATION declaration is known -->
                        <xsl:when test="exists(map:get($internal-subset-notations, $suffix))">
                            <xsl:text> PUBLIC &quot;</xsl:text>
                            <xsl:value-of select="map:get($notation-declarations, $suffix)"/>
                            <xsl:text>&quot;</xsl:text>
                        </xsl:when>
                        <!-- There is no known NOTATION declaration, so we just make one up -->
                        <!-- TBA or we add standardised NOTATION declarations to a common lookup -->
                        <xsl:otherwise>
                            <xsl:text> PUBLIC &quot;</xsl:text>
                            <xsl:value-of select="upper-case($suffix)"/>
                            <xsl:text>&quot; SYSTEM &quot;</xsl:text>
                            <xsl:value-of select="$suffix"/>
                            <xsl:text>&quot;</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <xsl:text>&gt;&#x0a;</xsl:text>
                </xsl:if>
            </xsl:iterate>
        </xsl:variable>
        
        
        <xsl:value-of select="$internal-subset"/>
    </xsl:template>
    
    
</xsl:stylesheet>