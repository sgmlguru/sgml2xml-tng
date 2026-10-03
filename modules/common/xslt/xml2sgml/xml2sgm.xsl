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
    
    
    <!-- Include the properties file and feed the inclusion element sequence from there -->
    
    <!-- Name of the module, e.g. 'ata' -->
    <xsl:param name="module" as="xs:string?"/>
	
	
	<xsl:variable name="root" select="name(/*)"/>
    
    
    <xsl:variable name="path" select="'../../../' || $module || '/schemas/'"/>
    
    <xsl:variable
        name="path-with-filename"
        select="if (doc-available($path || 'models.xml'))
        then ($path || 'models.xml')
        else ()"/>
    
    <xsl:variable
        name="inclusion-elements"
        select="tokenize(doc($path-with-filename)//doctype[matches($root, @root) and @target='sgml']/inclusions/empty/@value, ' ')"
        as="xs:string*"/>
    
    
    <!-- SGML inclusion elements, expressed as PIs in the input XML -->
    <xsl:variable name="sgml-inclusions" select="$inclusion-elements"/>
    <!-- ('revst','revend','effect','cocst','cocend','hotlink') -->
    
    
    <xsl:variable name="filename" select="tokenize(base-uri(/),'/')[last()]"/>
    <xsl:variable name="base-uri" select="substring-before(base-uri(/),$filename)"/>
    
    
    <xsl:template match="/">
        <xsl:message expand-text="yes">Module is {$module}, inclusion elements to be processed are  {string-join($inclusion-elements, ', ')}</xsl:message>
        <xsl:next-match/>
    </xsl:template>
    
    
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
    
    
    <xsl:template match="@licensed | @smmlevel | @bookcase-rev | @bookcase-nbr"/>
    
    
    <xsl:template match="@book-docnbr | @book-tsn | @book-revdate | @book-model"/>
    
    
    <xsl:template match="@xml:id"/>
    
    
    <xsl:template match="@*[starts-with(name(.), 'aug:')]" priority="10"/>
    
    
    <xsl:template match="@include-in-nlr" priority="10"/>
    
    
   
</xsl:stylesheet>