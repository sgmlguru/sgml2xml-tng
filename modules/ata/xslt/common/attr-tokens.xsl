<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:sg="http://www.sgmlguru.org/ns"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy" use-accumulators="#all"/>
    
    
    <xsl:template match="@chg | @numtype | @bulltype | @formal | @alt">
        <xsl:attribute name="{name(.)}" select="upper-case(.)"/>
    </xsl:template>
    
</xsl:stylesheet>