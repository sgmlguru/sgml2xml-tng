# Cases

This contains various cases and situations the model lookup XML files need to handle.


## Graphic Entities

Let's say we have an SGML document with a `graphic` element pointing to a graphic entity, like so:

```XML
<!DOCTYPE doc PUBLIC "-//CWORD//DTD DOC TEST//EN" "doc.dtd" [
<!ENTITY bill SYSTEM "Bill_Murray.jpg" NDATA jpeg >
]>
<doc>
    <title>My Test SGML Document</title>
    <chapter>
        <title>Chapter 2 Title</title>
        <para>More content.</para>
        <section>
            <title>Subsection 1 Title</title>
            <para>Subsection content.</para>
            <graphic name="bill">
        </section>
    </chapter>
</doc>
```

We want the XML version to be

```XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE doc PUBLIC "-//CWORD//DTD XML DOC TEST//EN" "doc.dtd">
<doc>
   <title>My Test SGML Document</title>
   <chapter>
      <title>Chapter 2 Title</title>
      <para>More content.</para>
      <section>
         <title>Subsection 1 Title</title>
         <para>Subsection content.</para>
         <graphic name="bill" href="Bill_Murray.jpg"/>
      </section>
   </chapter>
</doc>
```

The XML document's `graphic` element now has a `@href` pointing to the SGML entity's SYSTEM identifier.

I believe it's (more than) enough to have a mapping rule in the model lookup XML, like so:

```XML
<map source="name" target="href" A="ent" B="attr" start="sgml"/>
```

It should be easy to write an XSLT stylesheet that converts the entity reference to an attribute reference using the mapping information.


## Inclusion Elements in SGML

Inclusion elements in SGML are elements that are short-circuited into a model, *any* model, by declaring them as such. ATA's `revst` and `revend` elements, for example, are `EMPTY` elements inserted as inclusions to the root element, in most cases. This means that they are allowed *everywhere* in *every* descendant model. As you probably understand, this is a pain. And doubly so, because XML doesn't have such a construct, which means that if you want to allow the SGML elements in question everywhere in your XML DTD or schema, that DTD has to change. 

This is usually not doable without compromising everything else, so the XML DTD either needs a complete rewrite (which happens), or the inclusion elements are converted to something else, such as PIs. Let me explain.

The `revst` and `revend` elements are simply revision markers, start and end. They are used to generate change bars in the output, and really, they shouldn't actually not be allowed everywhere. It's just that the DTD designers were a lazy bunch and SGML allowed the shortcut. But really, anything will do to replace them. Attriutes could work... or processing instructions.

This is what I've done for some customers. Instead of

```XML
<p>Some <refst>new<revend> text.</p>
```

we get

```XML
<p>Some <?refst?>new<?revend?> text.</p>
```

in the XML. This works; it is entirely possible to treat them as pseudo-elements when needed, allowing us to generate change bars in the output.

Such inclusion elements are converted to PIs in the ATA module. If we list our `EMPTY` elements like so:

```XML
<inclusions>
    <!-- EMPTY elements, whitespace-separated -->
    <empty value="revst revend cocst cocend hotlink"/>
</inclusions>
```

We can then read the names into a sequence `$non-nested` and convert matching elements to PIs like so:

```XML
<xsl:template match="*[name(.) = $non-nested]">
    <xsl:processing-instruction name="{name(.)}">
        <xsl:for-each select="@*">
            <xsl:value-of select="name(.) || '=&quot;' || . || '&quot;'"/>
            <xsl:value-of select="if (position() != last()) then (' ') else ()"/>
        </xsl:for-each>
    </xsl:processing-instruction>
    
    <xsl:message expand-text="yes">
        Convert non-nested element {sg:get-xpath(.)} to PI
    </xsl:message>
</xsl:template>
```

This also handles any attributes in the input, converting them to pseudo-attributes in the PIs.


## Non-empty and Nested Inclusion Elements

Unfortunately, SGML's inclusion mechanism doesn't limit itself to empty elements. You can include any element, so we have two additional cases:

* Elements with character content
* Elements with children

And, of course, a mix of the two, i.e. mixed content. In them all, the difficulty is in modelling the XML version.


### Mixed Content

Since the intended use of this feature is to add options for a standardised conversion from SGML to XML, we may want to limit its use. For example, do we actually want to support mixed content by converting the SGML elements to XML PIs? I would advise against it, even though it's perfectly possible to do something like this:

```XML
<?p?>Some text<?end-p?>
```

(The `PITarget` production, i.e. PI name, doesn't allow starting with a '/'.)

I'd question the practicality of this approach, since clearly the intention is to enter text in the (pseudo-) element. Most XML editors wouldn't enforce pseudo-wellformedness, and it would be a pain to implement it.


### No Mixed Content, But Nesting

Nested SGML elements *without* text content are more straight-forward. Here's an ATA example of an `effect` element containing an `sbeff` element (note that ATA SGML element and attribute names are case-insensitive):

```XML
<LIST1 CONT="1"><L1ITEM CONT="1">
<EFFECT>
<SBEFF EFFTEXT="Old Oil Nozzle Design" SBNBR="72-0039" SBCOND="PRE SB">
</EFFECT>
<LIST2 CONT="1">
<L2ITEM><PARA>Remove the A/O seal nozzle (oil nozzle) (<CSN FIGNBR="45" ITEMNBR="240" CHAPNBR="72" SECTNBR="00" UNITNBR="02">) and A/O No.
5 nozzle (lube nozzle) (01509) by removing the self-locking nuts (nuts)
(01544). Remove and discard the preformed packing (01555, 0155B).
Refer to <REFINT REFID="TK72-00-04-020-801">TASK 72-00-04-020-801
(72-00-04, REMOVAL 001)</REFINT> and <GRPHCREF REFID="F72-00-00-02-002-209">Figure 207</GRPHCREF>.</PARA>
</L2ITEM>
</LIST2>
<EFFECT>
<SBEFF SBNBR="72-0039" SBCOND="END PRE SB">
</EFFECT>
</L1ITEM></LIST1>
```

Line breaks added to aid reading.

This is quite common in ATA to indicate effectivities "caused by" Service Bulletins, and they frequently appear in pairs to mark spans affected by an SB.

Converting the `effect/sbeff` structure to PIs is mostly straight-forward; converting the XML PIs back to SGML elements is sometimes more complex.

```XML
<?effect?>
<?sbeff efftext="Old Oil Nozzle Design" sbnbr="72-0039" sbcond="PRE SB"?>
```

(etc)

Note the pseudo-attributes and the lower-case tag naming. The latter is, of course, a choice you'll have to make when planning the SGML to XML conversion. I tend to go with lower-case.

