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
    
    <!-- DOCTYPE lookup for PUBLIC and SYSTEM IDs -->
    <xsl:param
        name="doctype-lookup-uri"
        select="'./doctype-lookup.xml'"/>
    <xsl:variable
        name="doctype-lookup"
        select="doc($doctype-lookup-uri)"/>
    
    <!-- NOTATION lookup for internal subset -->
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
    <xsl:variable
        name="internal-subset-notations"
        as="map(*)"
        select="map {'cortona3d' : 'CORTONA3D'}"/>
    
    <!-- Known internal subset-only NOTATION declarations -->
    <xsl:variable
        name="notation-declarations"
        as="map(*)"
        select="map {
        'cortona3d' : '-//CORTONA3D//NOTATION C3D Packages Encoding//EN'}"/>
    
    <xsl:template match="/">
        <xsl:variable
            name="root"
            select="name(/*)"/>
        <!-- Output only PUBLIC ID so receiver won't try to map the SYSTEM ID -->
        <xsl:variable
            name="doctype"
            select="'&lt;!DOCTYPE ' || $root || ' PUBLIC &quot;' ||
                        ($doctype-lookup//doctype[@root=$root])/publicid ||
                        '&quot; [&#x0a;'"/>
        
        <xsl:message expand-text="yes">
            Root {$root}
            Doctype {$doctype}
        </xsl:message>
        
        <xsl:value-of select="$doctype"/>
        
        <xsl:variable name="entities">
            <xsl:apply-templates select=".//(sheet | grsymbol | refmedia)" mode="entities"/>
        </xsl:variable>
        
        <xsl:variable name="notations">
            <xsl:apply-templates select=".//(sheet | grsymbol | refmedia)" mode="notations"/>
        </xsl:variable>
        
        <xsl:value-of
            select="string-join(distinct-values(tokenize($entities, '&#x0a;')), '&#x0a;') ||
                    '&#x0a;' ||
                    string-join(distinct-values(tokenize($notations, '&#x0a;')), '&#x0a;')"/>
        
        <xsl:text>&#x0a;]&gt;</xsl:text>
    </xsl:template>
    
    
    <xsl:template match="sheet | grsymbol | refmedia" mode="entities">
        <xsl:variable
            name="href"
            select="processing-instruction('href')"/>
        <xsl:variable
            name="cfhref"
            select="processing-instruction('cfhref')"/>
        
        <xsl:variable name="internal-subset">
            <xsl:iterate select="@gnbr, @cfnbr">
                <xsl:variable
                    name="suffix"
                    select="if (name(.) = 'gnbr')
                    then (replace($href,'^(.*)\.([a-zA-Z0-9]+)$','$2'))
                    else (replace($cfhref,'^(.*)\.([a-zA-Z0-9]+)$','$2'))"/>
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
                <xsl:value-of select="."/>
                <xsl:text> SYSTEM &quot;</xsl:text>
                <xsl:value-of select="if (name(.) = 'gnbr') then ($href) else ($cfhref)"/>
                <xsl:text>&quot; NDATA </xsl:text>
                <xsl:value-of select="$current-notation"/>
                <xsl:text>&gt;&#x0a;</xsl:text>
            </xsl:iterate>
        </xsl:variable>
        
        
        <xsl:value-of select="$internal-subset"/>
    </xsl:template>
    
    
    <xsl:template match="sheet | grsymbol | refmedia" mode="notations">
        <xsl:variable
            name="href"
            select="processing-instruction('href')"/>
        <xsl:variable
            name="cfhref"
            select="processing-instruction('cfhref')"/>
        
        <xsl:variable name="internal-subset">
            <xsl:iterate select="@gnbr, @cfnbr">
                <xsl:variable
                    name="suffix"
                    select="if (name(.) = 'gnbr')
                    then (replace($href,'^(.*)\.([a-zA-Z0-9]+)$','$2'))
                    else (replace($cfhref,'^(.*)\.([a-zA-Z0-9]+)$','$2'))"/>
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