<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sgproc="http://www.sgmlguru.org/ns/xproc/steps"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    name="ata-migration"
    type="sgproc:ata-migration"
    version="3.0">
    
    <p:documentation>
        <p>This is the wrapper XProc pipeline for converting ATA-like well-formed XML to valid ATA XML</p>
    </p:documentation>
    
    <p:import href="../../../lib/xproc-batch/xproc/validate-convert.xpl"/>
    
    <p:input port="manifest" select="''" sequence="true"/>
    
    <p:input port="sch" select="'../sch/ata-checks.sch'"/>
    
    <p:input port="doctypes" href="./doctype-lookup.xml"/>
    
    <p:output port="result" serialization="map{'indent' : true()}" sequence="true"/>
    
    <p:option name="input-base-uri" required="true" as="xs:string"/>
    
    <p:option name="output-base-uri" required="false" as="xs:string"/>
    
    <p:option name="reports-dir" required="false" as="xs:string"/>
    
    <p:option name="tmp-dir" required="true" as="xs:string"/>
    
    <p:option name="include" required="false" as="xs:string?" select="'.xml'"/>
    
    <p:option name="exclude-filter" required="false" as="xs:string?" select="'\.jpg'"/>
    
    <p:option name="debug" required="true" as="xs:string"/>
    
    
    <p:variable
        name="include-filter"
        select="if (starts-with($include, '.')) then ('\' || $include) else ($include)"/>
    
    
    <p:for-each name="loop-doctypes">
        <p:with-input select="//doctype[@root!='' and @include='true']" pipe="doctypes@ata-migration"/>
        
        <!-- Get DOCTYPE properties for conversion -->
        <p:variable name="root" select="string(/doctype/@root)" as="xs:string"/>
        <p:variable name="xslt-manifest" select="/doctype/xslt-manifest" as="xs:string"/>
        <p:variable name="xspec-manifest" select="/doctype/xspec-manifest" as="xs:string"/>
        <p:variable name="xml-publicid" select="/doctype/xml-publicid" as="xs:string"/>
        <p:variable name="xml-systemid" select="/doctype/xml-systemid" as="xs:string"/>
        
        
        <!-- Convert based on DOCTYPE properties -->
        <sgproc:validate-convert name="run" p:message="Processing {$root} documents with include filter {$include-filter}">
            <p:with-input port="manifest">
                <p:document href="../pipelines/{$xslt-manifest}"/>
            </p:with-input>
            <p:with-input port="sch" pipe="sch@ata-migration"/>
            <p:with-option name="input-base-uri" select="$input-base-uri"/>
            <p:with-option name="output-base-uri" select="if ($output-base-uri != '') then $output-base-uri else concat($tmp-dir, '/out')" />
            <p:with-option name="reports-dir" select="if ($reports-dir != '') then $reports-dir else concat($tmp-dir, '/reports')" />
            <p:with-option name="tmp-dir" select="$tmp-dir"/>
            <p:with-option name="include-filter" select="$include-filter"/>
            <p:with-option name="exclude-filter" select="$exclude-filter"/>
            <p:with-option name="root-filter" select="$root"/>
            <p:with-option name="doctype-public" select="$xml-publicid"/>
            <p:with-option name="doctype-system" select="$xml-systemid"/>
            <!--<p:with-option name="xspec-manifest-uri" select=""/>-->
            <p:with-option name="verbose" select="'true'"/>
            <p:with-option name="debug" select="$debug"/>
            <p:with-option name="dtd-validate-input" select="'false'"/>
            <p:with-option name="dtd-validate-output" select="'false'"/>
            <p:with-option name="sch-validate-output" select="'false'"/>
            <p:with-option name="run-xspecs" select="'false'"/>
        </sgproc:validate-convert>
        
    </p:for-each>
    
</p:declare-step>