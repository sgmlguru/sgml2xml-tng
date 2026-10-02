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
        <xsl:variable
            name="root"
            select="name(/*)"/>
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
        </xsl:message>
        
        <xsl:value-of select="$doctype"/>
        
        <!-- TBA Get elements from models.xml -->
        <xsl:variable name="entities">
            <xsl:apply-templates select=".//(sheet | grsymbol | refmedia)" mode="entities"/>
        </xsl:variable>
        
        <!-- TBA Get elements from models.xml -->
        <xsl:variable name="notations">
            <xsl:apply-templates select=".//(sheet | grsymbol | refmedia)" mode="notations"/>
        </xsl:variable>
        
        <xsl:value-of
            select="string-join(distinct-values(tokenize($entities, '&#x0a;')), '&#x0a;') ||
                    '&#x0a;' ||
                    string-join(distinct-values(tokenize($notations, '&#x0a;')), '&#x0a;')"/>
        
        <xsl:text>&#x0a;]&gt;</xsl:text>
    </xsl:template>
    
    
    <!-- TBA Rewrite to handle external list of elements -->
    <!-- TBA Get elements from models.xml -->
    <xsl:template match="sheet | grsymbol | refmedia" mode="entities">
        <xsl:variable
            name="href"
            select="processing-instruction('href')"/>
        <xsl:variable
            name="cfhref"
            select="processing-instruction('cfhref')"/>
        
        <!-- TBA Get attribute names from models.xml; the attr to be used here depends on the template context -->
        <xsl:variable name="internal-subset">
            <xsl:iterate select="@gnbr, @cfnbr">
                
                <!-- TBA Needs to be generalised (or pulled from models.xml entry) -->
                <xsl:variable
                    name="suffix"
                    select="if (name(.) = 'gnbr')
                    then (replace($href,'^(.*)\.([a-zA-Z0-9]+)$','$2'))
                    else (replace($cfhref,'^(.*)\.([a-zA-Z0-9]+)$','$2'))"/>
                
                <!-- TBA models.xml and notations dependency; should be generalised -->
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
    
    
    <!-- TBA Get elements from models.xml -->
    <xsl:template match="sheet | grsymbol | refmedia" mode="notations">
        
        <!-- TBA needs to be rewritten to handle template context and models.xml -->
        <xsl:variable
            name="href"
            select="processing-instruction('href')"/>
        
        <!-- TBA needs to be rewritten to handle template context and models.xml -->
        <xsl:variable
            name="cfhref"
            select="processing-instruction('cfhref')"/>
        
        <!-- TBA needs to be rewritten to handle template context and models.xml -->
        <!-- TBA Get attr names from models.xml and template context -->
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
                <!-- TBA need logic, additions to models.xml or a common NOTATION lookup -->
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