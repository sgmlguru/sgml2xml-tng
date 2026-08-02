<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:aug="http://cadituk.com/ns/xml/augmentation"
    exclude-result-prefixes="xs math xi aug"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy" use-accumulators="#all"/>
    
    
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="para"/>	
    
    <xsl:output method="xml" indent="false"/>
    
    
    <!-- SGML inclusion elements, expressed as PIs in the input XML -->
    <xsl:variable name="sgml-inclusions" select="('revst','revend','effect','cocst','cocend','hotlink')"/>
    
    
    <xsl:variable name="filename" select="tokenize(base-uri(/),'/')[last()]"/>
    <xsl:variable name="base-uri" select="substring-before(base-uri(/),$filename)"/>
    
    
    <!-- Convert any listed PIs in $sgml-inclusions to elements -->
    <xsl:template match="processing-instruction()[name(.)=$sgml-inclusions]">
        <xsl:call-template name="pi">
            <xsl:with-param name="name" select="name(.)"/>
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    
    <!-- These can only exist inside an effect, so deleted here -->
    <xsl:template match="processing-instruction('coceff') | processing-instruction('sbeff') | processing-instruction('effsb')"/>
    
    
    <!-- Nested inside effect -->
    <xsl:template match="processing-instruction('coceff') | processing-instruction('sbeff') | processing-instruction('effsb')" mode="nested">
        <xsl:call-template name="pi">
            <xsl:with-param name="name" select="name(.)"/>
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    
    <xsl:template name="pi">
        <!-- Name of the PI -->
        <xsl:param name="name"/>
        <!-- PI contents (pseudo attrs) -->
        <xsl:param name="text"/>
        <!-- Identifier for the current PI, required to avoid nesting too many PIs -->
        <xsl:variable name="id" select="generate-id(.)"/>
        <!-- Identifier for the next root-level PI ($sgml-inclusions, see above) -->
        <xsl:variable name="next-id" select="generate-id(following-sibling::processing-instruction()[name(.) = $sgml-inclusions][1])"/>
        
        <xsl:element name="{name(.)}" exclude-result-prefixes="#all">
            
            <!-- Iterate through pseudo attrs -->
            <xsl:call-template name="pseudo-attrs">
                <xsl:with-param name="text" select="$text"/>
            </xsl:call-template>
            
            <!-- <effect> sometimes contains nested sbeff, effsb (SB documents) or coceff -->
            <xsl:if 
                test="self::processing-instruction('effect') and 
                (following-sibling::node()[not(self::text())][1][self::processing-instruction('sbeff') or 
                self::processing-instruction('coceff') 
                or self::processing-instruction('effsb')])">
                
                <!-- We don't want to look at the *next* $sgml-inclusions PI, just any nested ones -->
                <xsl:apply-templates
                    select="following-sibling::processing-instruction()[name(.)=('sbeff','coceff','effsb') and 
                    not(preceding-sibling::*[preceding-sibling::node()[generate-id(.)=$id]]) and not(preceding-sibling::node()[name(.) = $sgml-inclusions and generate-id(.) = $next-id])]"
                    mode="nested"/>
            </xsl:if>
            
        </xsl:element>
    </xsl:template>
    
    
    <!-- Pseudo-attributes to real attributes -->
    <xsl:template name="pseudo-attrs">
        <xsl:param name="text"/>
        
        <!-- We tokenise on whitespace below, so we need to 
             normalise the leading pseudo attr values first -->
        <xsl:variable name="normalised-text" select="replace($text, '(=&quot;)[\s]+', '$1')"/>
        
        <xsl:for-each select="tokenize($normalised-text,'&quot;\s')">
            <xsl:analyze-string select="." regex="^([^=]+)=&quot;([^&quot;]*)&quot;?$">
                <xsl:matching-substring>
                    <xsl:attribute name="{regex-group(1)}" select="regex-group(2)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- Remove @href, @cfhref but keep them as PIs
         Keep @gbnbr, @mednbr, @cfnbr as-is if they exist, 
         otherwise base them on the @href/@cfhref but remove
         revision and $ separator as the $ is disallowed in the SGML -->
    <xsl:template match="sheet | grsymbol | refmedia" exclude-result-prefixes="#all">
        <xsl:variable name="gnbr" select="@gnbr"/>
        <xsl:variable name="cfnbr" select="@cfnbr"/>
        <xsl:variable name="mednbr" select="@mednbr"/>
        
        <xsl:element name="{name(.)}">
            <xsl:apply-templates select="@* except (@href, @cfhref,@gnbr, @mednbr, @cfnbr)"/>
            
            <xsl:attribute
                name="{if (self::refmedia) then ('mednbr') else ('gnbr')}">
                <xsl:choose>
                    <xsl:when test="@mednbr">
                        <xsl:value-of select="$mednbr"/>
                    </xsl:when>
                    <xsl:when test="@gnbr">
                        <xsl:value-of select="$gnbr"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="replace(@href,'^([a-zA-Z0-9]*\$)?(.+)\.[a-zA-Z]+$','$2')"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:attribute>
            
            <xsl:if test="@cfhref">
                <xsl:attribute
                    name="cfnbr">
                    <xsl:choose>
                        <xsl:when test="exists(@cfnbr)">
                            <xsl:value-of select="$cfnbr"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="replace(@cfhref,'^([a-zA-Z0-9]*\$)?(.+)\.[a-zA-Z]+$','$2')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:attribute>
                <xsl:processing-instruction name="cfhref" select="@cfhref"/>
            </xsl:if>
            
            <!-- Occurs in sheet, grsymbol, refmedia -->
            <xsl:if test="@href">
                <xsl:processing-instruction name="href" select="@href"/>
            </xsl:if>
            
            <xsl:apply-templates select="node()" exclude-result-prefixes="#all"/>
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template match="@licensed | @smmlevel | @bookcase-rev | @bookcase-nbr"/>
    
    
    <xsl:template match="@book-docnbr | @book-tsn | @book-revdate | @book-model"/>
    
    
    <xsl:template match="@xml:id"/>
    
    
    <xsl:template match="@*[starts-with(name(.), 'aug:')]" priority="10"/>
    
    
    <xsl:template match="@include-in-nlr" priority="10"/>
    
    
   
</xsl:stylesheet>