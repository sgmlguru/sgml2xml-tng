# README

This repository contains code and resources to convert SGML documents to well-formed XML, optionally valid against a specified XML DTD (XSDs and RNGs not yet supported).


## Prerequisites

* OpenJDK version 8, 11, or later - other versions may cause issues
* [Ant](https://ant.apache.org/bindownload.cgi)
* [Ant-contrib](https://sourceforge.net/projects/ant-contrib/files/ant-contrib/1.0b3/ant-contrib-1.0b3-bin.zip/download)


## Setup

Set up the pipeline thusly:

1. Add the AntContrib JAR file to `~/.ant/lib` or `$ANT_HOME/lib`
2. Create a local build properties file by saving `build.properties.localRENAME.xml` in the current folder as `build.properties.local.xml`.
3. (OPTIONAL) If you want to produce something more than well-formed XML, set the `${wellformed-only}` property to 'false' in `build.properties.local.xml`.
4. (OPTIONAL) Add a module that defines your source SGML and target XML formats, as well as any transformations that need to take place, in `modules/`. See TBA for instructions.
5. (OPTIONAL) Set the name of the module as the value of the `${current-module}` property in `build.properties.local.xml`.


## Sources Setup

The SGML sources *must* be set up as follows:

```
</path/to/base/dir>/
	<fileset>
		data/
			(SGML files)
```

`/path/to/base/dir` is a base path to subfolders, each of whch contains a separate folder with a set of SGML files to be converted. Each of those folders (`fileset`, above) needs to contain a folder named `data`, in which the SGML files live. Thus, the full path to the SGML file(s) is `</path/to/base/dir/fileset>/data/**/*.sgm`.

Note that source subdirectories are preserved in the output.

The migration outputs the following:

```
</path/to/base/dir>/
	<fileset>
		data/
			(SGML files)
		tmp/
			<dateTimeStamp>/
				debug/
				out/
                pre/
				reports/
				spam/
				sx/
				xml/
```

Valid XML (optional) is saved in `out`. Subfolder structures inside `data` are preserved.

There are multiple debug folders:

* `spam` contains the normalised SGML
* `sx` contains the well-formed XML before UTF-8 serialisation
* `xml` contains the well-formed XML serialised in UTF-8
* `debug` contains the pipeline debug output for each file and pipeline step
* `reports` contains a number of log files to trace the performed operations


### Adding New Sources

Add source filesets by editing `build.properties.local.xml`, as follows:

1. Update the *base path* (`${base.dir}`) property - this is `/path/to/base/dir`, above.
2. For each set of files, update the folder name (`${env.src}`) property of that set (`fileset` in the above example) - it is assumed that the folder is a subfolder to the base path, and it is further assumed that that folder contains a subfolder called `data` where the sources live.


### Mapping Graphic Entities

The example SGML DTD declares a `graphic` element that links to graphics using either a graphic entity named in `@name` or via a direct reference in `@href`. The graphic entity is converted to a direct reference via the `@href` attribute when transforming everything to XML. This is an example DTD only, and it goes without saying that horrible things will happen if you create an SGML instance that has a `graphic` element using both mechanisms and then convert it to XML. It's an example, for goodness sake.

The entity-to-href conversion currently happens in `modules/common/map-unparsed-entities.xsl`. This is very, very crude and I apologise for it. It will change.


## Modules

A *module* is a set of files (SGML and XML DTDs or schemas, catalogs, SGML declarations, XSLTs, XProc pipelines, etc) that does the following:

* Fully defines the SGML sources
	* SGML DTDs
	* SGML declaration(s)
	* Catalog files
	* Entities
* Fully defines the XML output files
	* XML DTDs/schemas
	* Catalog files
	* Pipeline manifests
	* XProc and XSLT
	* (etc)

The idea is to gather all necessary files to validate the sources and targets, normalise the SGML into files with the `DOCTYPE` declarations containing the entire DTDs in the internal subset, convert that SGML into well-formed XML with XML character entity declarations in an internal `DOCTYPE` subset and then into well-formed, UTF-8-encoded XML, and then, finally, run an XProc pipeline that produces valid XML.

A module structure will look something like this:

```XML
modules/<module>
├── pipelines
├── sch
├── schemas
│   ├── sgml
│   │   ├── dtd
│   └── xml
│       ├── dtd
│       ├── mod
├── xproc
└── xslt
```

The module itself (the folder in `modules`) should be named descriptively, so `ata`, `s1000d`, etc. As for the contents, there's bound to be some variation but the above would have the following:

* `pipelines` - a manifest file listing the XSLT steps that transform the well-formed XML into valid files
* `sch` - Schematron rules you may want to validate the output with
* `schemas`
	* `sgml` - SGML DTDs, catalogs, SGML declarations; `modules/common` contains some common entities
	* `xml` - XML DTDs, schemas, modules, catalogs; the XML requires OASIS XML catalogs
* `xproc` - XProc pipelines; importantly, you'll need an initial pipeline that will iterate through your well-formed XML to determine the XML schema
* `xslt` - the XSLT files used by the manifest in `pipelines`

Each module *must* also have an Ant properties file named `MODULE_NAME.properties.xml`, where `MODULE_NAME` is the module's name. It needs to be directly inside the `MODULE_NAME` folder and should look something like this:

```XML
<properties>
    
    <module location="${modules}/NAME">
        <schemas location="${module}/schemas">
            <!-- SGML -->
            <input location="${module.schemas}/sgml/catalog.txt"/>
            <!-- SGML to XML conversion -->
            <output location="${module.schemas}/sgml/catalog_sgml2xml.txt"/>
            <!-- ATA resources -->
            <resources>
                <ent location="${module.schemas}/sgml/ISOent-declarations-xml.txt"/>
            </resources>
        </schemas>
        
        <!-- Schematron -->
        <sch location="${module}/sch/NAME.sch"/>
        
        <!-- XProc pipeline manifests and libs -->
        <pipeline>
            <manifest location="${module}/pipelines/NAME-xslt-manifest.xml"/>
            <xproc location="${module}/xproc/NAME-migration.xpl"/>
        </pipeline>
    </module>
    
</properties>
```

The XSLT pipelines use the [xproc-batch](https://github.com/sgmlguru/xproc-batch) library. That repository's README should explain how to use them. You should take a look at the `ata` and `s1000d` modules for ideas on how to process your well-formed XML.

The `modules/doc` folder also contains a perfectly trivial SGML DTD and associated examples that may prove to be helpful.


### ATA Module

The ATA module transforms ATA iSpec 2200 SGML instances to an "ATA-like" XML format. Graphic entities in the SGML are handled using direct, `@href`-based references in the XML, and some SGML constructs introduced using SGML inclusions are represented using XML processing instructions. This is far from ideal, even though the SGML inclusion elements were all `EMPTY` elements. In an ideal world, those PIs would be modelled differently. This, however, is just a proof of concept.

There is a `modules/ata/ata.properties.xml` file:

```XML
<properties>
    
    <module location="${modules}/ata">
        <schemas location="${module}/schemas">
            <!-- SGML -->
            <input location="${module.schemas}/sgml/catalog.txt"/>
            <!-- SGML to XML conversion -->
            <output location="${module.schemas}/sgml/catalog_sgml2xml.txt"/>
            <!-- ATA resources -->
            <resources>
                <ent location="${module.schemas}/sgml/ISOent-declarations-xml.txt"/>
            </resources>
        </schemas>
        
        <!-- Schematron -->
        <sch location="${module}/sch/ata-checks.sch"/>
        
        <!-- XProc pipeline manifests and libs -->
        <pipeline>
            <manifest location="${module}/pipelines/ataxml-xslt-manifest.xml"/>
            <xproc location="${module}/xproc/ata-migration.xpl"/>
        </pipeline>
    </module>
    
</properties>
```


#### Missing DTDs?

The SGML and XML ATA DTDs cannot be part of this repository as they are owned by their respective copyright holders. You need to buy the ATA iSpec 2200 DTDs if you wish to use the ATA module; similarly, you will then need to create XML versions of those DTDs.

Also keep in mind that the ATA module contains catalog files and SGML declarations specific to the DTDs I cannot include in the repo. You'll need to make sure to update those catalog files for the versions you are using.


### S1000D Module

The S1000D module cannot contain the actual 1.8 DTDs or 4.1 XSDs, as those are owned by their respective copyright holders. You can get these from the [S1000D website](https://s1000d.org/) if you register and agree to their [Terms and Conditions](https://s1000d.org/?page_id=108).

The 1.8 DTD files should go in `modules/s1000d/schemas/sgml/1.8/dtd/`. The 4.1 XSDs should go in `TBA`.


## Running

Set up the sources as described above. Then run `build.xml` without arguments.

