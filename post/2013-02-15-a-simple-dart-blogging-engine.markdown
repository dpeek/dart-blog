---
title: A Simple Dart Blogging Engine
date: 2013-02-15 20:12
---

This blog documents my experiences learning [Dart][dart], getting to know the 
[language][spec], [libraries][core], [toolchain][editor], and 
[community][community]. As a learning project I'll be building a simple static 
site generator similar to [Jekyll][jekyll]. I don't have big plans for the 
project, but hopefully others will find it a useful reference.

The source for this site is available on [GitHub][source].

## Objectives

The basic goal is to convert a collection of [Markdown][markdown] documents 
into HTML: an index/archive and a page for each post. Additional post metadata 
(title, tags) will be defined in a [YAML](yaml) front matter, parsed into a 
model and used to generate each page.

So here are the requirements:

* Listing and reading markdown from the file system
* Parsing the YAML front matter
* Converting Markdown to HTML, hopefully with support for syntax highlighting
* Generating HTML for the index/pages from templates
* Paginating the index (once I have enough posts)
* Generating an RSS feed

## Next steps

Next up I'll look at what's available already on [pub][pub] that meets my 
needs. No point inventing wheels where I don't have to (as much as I love 
reinventing wheels).

[core]: http://www.dartlang.org/docs/dart-up-and-running/contents/ch03.html
[spec]: http://www.dartlang.org/docs/spec
[community]: https://groups.google.com/a/dartlang.org/forum
[editor]: http://www.dartlang.org/docs/editor
[dart]: http://www.dartlang.org
[yaml]: http://yaml.org
[markdown]: http://daringfireball.net/projects/markdown
[source]: https://github.com/dpeek/blog
[jekyll]: http://jekyllrb.com
[pub]: http://pub.dartlang.org
