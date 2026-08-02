<?xml version="1.0" encoding="UTF-8"?>
<sch:schema
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    
    <sch:title>Test Rules</sch:title>
    
    
    <sch:pattern>
        <sch:title>Empty content</sch:title>
        <sch:rule context="p | title">
            <sch:report test="not(*) and normalize-space(string-join(text()))=''"><sch:value-of select="name(.)"/> is empty.</sch:report>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>