### 1.5.2

* fix wrong return code on failed resolve

### 1.5.1

* do proper tag resolving with semver for github archive URLs

## 1.5.0

* mulle-domain understands zipball and tarball github URLs now


## 1.4.0

* the github: shortcut now understands .zip and .tar file extension and optionally also a @`<tag>` suffix


## 1.3.0

* added some more convenience aliases for guess commands
* the 'homepage' scm is now more lenient with respect to incoming data
* new domain 'clib' for C clib URLs
* new **homepage-url** command
* fix host parsing for domains like github:foo/bar and the like
* fix cross-platform problems
* the parser will now also output the host and not just the domain
* don't require tools, that actually might `_not_` be needed
* fix parsing of domain for git@github.com:


## 1.1.0

* somewhat better detection of the "file" scm


### 1.0.1

* Various small improvements

# 1.0.0

* big function rename to `<tool>`::`<file>`::`<function>` to make it easier to read hopefully
* improved parse of generic URLs
* added a hack to parse github releases/download archives a bit better
* somewhat more consistent handling of default scm during compose
* can now run with zsh, if bash is not available


### 0.0.1

* add hackish sourceforge plugin for tar.gz only
* added generic plugin, for non-github/gitlab URLS
* added --domain option to resolve
* split off mulle-domain from mulle-fetch
