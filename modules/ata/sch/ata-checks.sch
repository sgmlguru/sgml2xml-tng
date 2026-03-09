<?xml version="1.0" encoding="UTF-8"?>
<sch:schema
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    
    <sch:title>Rules for ATA EM and SB DTDs</sch:title>
    
    
    <sch:pattern>
        <sch:title>Attributes allowing numeric values only</sch:title>
        <sch:rule context="@revdate | @oidate | @efflen | @issdate | @chapnbr | @sectnbr | @subjnbr | @pgblknbr | @cols | @colnum | @morerows">
            <sch:assert test="matches(.,'^[0-9]+$')">Only numeric characters are allowed. Current value is <sch:value-of select="."/>.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    
    <sch:pattern>
        <sch:title>Attributes allowing a list of numeric tokens</sch:title>
        <sch:rule context="@chapsect">
            <sch:assert test="matches(.,'^([0-9]+[\s]*)+$')">Only a list of tokens containing numeric characters and separated by whitespace are allowed. Current value is <sch:value-of select="."/>.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    
    <sch:pattern>
        <sch:title>Nested tables not allowed</sch:title>
        <sch:rule context="table//ftnote | table//entry">
            <sch:report test=".//table">Tables are not allowed inside tables.</sch:report>
        </sch:rule>
    </sch:pattern>
    
    
    <sch:pattern>
        <sch:title>Empty content</sch:title>
        <sch:rule context="para | title | equ">
            <sch:report test="not(*) and normalize-space(string-join(text()))=''"><sch:value-of select="name(.)"/> is empty.</sch:report>
        </sch:rule>
    </sch:pattern>
    
    
    <sch:pattern>
        <sch:title>Nested notes</sch:title>
        <sch:rule context="note | caution | warning">
            <sch:report test=".//note | .//caution | .//warning">Notes, cautions, and warnings are not allowed to be nested.</sch:report>
        </sch:rule>
    </sch:pattern>
    
    
    <sch:pattern>
        <sch:title>Graphic placement</sch:title>
        <sch:rule context="tssect | sbfmsect | matsect | ftnote | gdesc">
            <sch:report test=".//graphic">Graphics are not allowed in <sch:value-of select="name(.)"/>.</sch:report>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>