<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy" use-accumulators="#all"/>
    
    <!-- ISO char maps included here -->
    <xsl:include href="charmaps/iso9573-2003map.xsl"/>
    
    <xsl:output
        method="xhtml"
        indent="0"
        use-character-maps="isoamsa isoamsb isoamsc isoamsn isoamso isoamsr isolat1 isolat2 isobox isodia isotech isogrk1 isogrk2 isogrk3 isogrk4 isocyr1 isocyr2 isopub isonum"/>
    
    
    
    <xsl:param
        name="repos.ata-dtds" select="'/home/ari/Documents/repos/siemens/xml2sgml/ata-dtds'"/>
    
    
    <xsl:variable
        name="isoent-declarations"
        select="(if (starts-with($repos.ata-dtds,'file:/')) then () else ('file:/')) || replace($repos.ata-dtds,'\\','/') || '/sgml/ISOent-declarations-xml.txt'"
        as="xs:string"/>
    
    <xsl:variable
        name="entity-declarations"
        select="unparsed-text($isoent-declarations)" as="xs:string"/>
    
    <xsl:variable name="entities-absolute-paths">
        <xsl:value-of
            select="replace($entity-declarations,
                            '&quot;xml-entities',
                            ('&quot;' || replace($repos.ata-dtds,'\\','/') || '/xml-entities'))"/>
    </xsl:variable>
    
    
    <xsl:template match="/">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE </xsl:text>
        <xsl:value-of select="name(*)"/>
        <xsl:text disable-output-escaping="yes"> [</xsl:text>
        <xsl:value-of select="$entities-absolute-paths" disable-output-escaping="yes"/>
        <xsl:text disable-output-escaping="yes">]&gt;</xsl:text>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    
    <!-- Remove href PIs -->
    <xsl:template match="processing-instruction(href)"/>
    
</xsl:stylesheet>