# README

This contains an Ant script that unzips a given source directory structure containing zip archives to a target URL, replicating the source directory structure.


## Setup

**NOTE!** Use forward slashes in your paths, i.e. 'c:/path/to/sources/'.

1. Make a copy of `build.properties.xml` named `build.properties.local.xml`. Open the copy in an XML editor.
2. Set a base directory for the sources in `${base.dir}`. The actual source files should be inside a subfolder `${env.src}` and its subfolders.
3. Set `${env.src}` for the folder containing your zip archives.

Your zip archives, then, should be in `${base.dir}/${env.src}`.


## Running

Run `ant` without arguments in the folder where your `build.xml` lives.
