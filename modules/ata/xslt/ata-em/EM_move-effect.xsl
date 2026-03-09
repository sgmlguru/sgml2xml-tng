<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:sg="http://www.sgmlguru.org/ns"
    exclude-result-prefixes="xs math sg"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy" use-accumulators="#all"/>
    
    <xsl:variable
        name="nested"
        select="('effect', 'sbeff', 'coceff')"
        as="xs:string*"/>
    
    
    <xsl:template match="subtask">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="*[self::effect and position() = 1 to (last()-1)]"/>
            <xsl:apply-templates select="*[not(self::effect) and position() != last()]"/>
            <xsl:apply-templates select="*[last()]"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>