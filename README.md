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

The entity-to-href conversion currently happens in `modules/common/map-unparsed-entities.xsl`. This is very, very crude and I aplogise for it. It will change.


## XML Output Modules

TBA


## Running

Set up the sources as described above. Then do this:

1. Open a shell (aka command prompt).
2. Change the current directory to the location where the pipeline Ant build script is located.
3. Type `ant` and hit **Enter**.

