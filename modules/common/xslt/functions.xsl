<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:sg="http://www.sgmlguru.org/ns"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    
    <xsl:function name="sg:get-xpath">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="'/' || string-join(for $p in $context/ancestor-or-self::* return (name($p) || '[' || (count($p/preceding-sibling::*[name(.)=name($p)]) + 1) || ']'),'/')"/>
    </xsl:function>
    
</xsl:stylesheet>