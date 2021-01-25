# mulle-domain

🏰 URL management and tag resolution for repositories

![Last version](https://img.shields.io/github/tag/mulle-sde/mulle-domain.svg)

Parses archive and repository URLs like
`https://github.com/mulle-sde/mulle-sde-developer.git` to determine the project
name `mulle-sde-developer` in this case. Also composes URLs bases on the
hoster domain and the project name.

mulle-domain has a plugin API, to manage multiple hosting domains such as
**github** or **gitlab**.

With the help of the hosters public API and
[mulle-semver](//github.com/mulle-sde/mulle-semver), mulle-domain can resolve
[semver](https://docs.npmjs.com/cli/v6/using-npm/semver/) qualifiers like
`~2.0.0` to generate the proper archive URL to fetch.



## Commands

Executable          | Description
--------------------|--------------------------------
`mulle-domain`      | URL management and tag resolution for repositories


### commit-for-tag

```
mulle-domain commit-for-tag https://github.com/mulle-c/mulle-c11 latest
```

Get the commit identifier (usually the sha hash) of a repository for the
given tag.


### compose-url

```
mulle-domain compose-url --tag 1.0.0 --user foo --repo bar gitlab
```

Create an URL to download the version 1.0.0 archive from gitlab of the
project bar of user foo.


### list

```
mulle-domain list
```

List known domains. Currently, that's **gihub**, **gitlab** and **sh** (sh.rt)


### nameguess

```
mulle-domain nameguess https://github.com/mulle-c/mulle-c11.git
```

Given an URL guess the proper name of the project. In this case it would be
`mulle-c11`. Can fail miserably for unknown domains.


### parse-url

```
mulle-domain parse-url https://github.com/mulle-c/mulle-c11.git
```

Breaks an URL apart into the constituent parts of interest for dependency URLs.



### tag-aliases

```
mulle-domain tag-aliases https://github.com/mulle-c/mulle-c11.git latest
```

Find tags that reference the same commit. By default will only list
semantic version (semver) compatible tags.


### tags

```
mulle-domain tags https://github.com/mulle-c/mulle-c11.git
```
List available tags. By default will only list semantic version (semver)
compatible tags.


### tags-for-commit

```
mulle-domain tags-for-commit https://github.com/mulle-c/mulle-c11.git e8dfhf
```

List all tags for a given the commit identifier. By default will only list
semantic version (semver) compatible tags. The commit identifier can not
be shortened.


### tags-with-commits

```
mulle-domain tags-with-commits https://github.com/mulle-c/mulle-c11.git e8dfhf
```

Lists all tags with the corresponding

### typeguess

```
mulle-domain typeguess https://github.com/mulle-c/mulle-c11.git
```

Given an URL guess the source code management (scm) form employed. Ususally
thats `git` or `tar`.


## Install

See [mulle-sde-developer](//github.com/mulle-sde/mulle-sde-developer) how
to install mulle-sde.



## Author

[Nat!](//www.mulle-kybernetik.com/weblog) for
[Mulle kybernetiK](//www.mulle-kybernetik.com) and
[Codeon GmbH](//www.codeon.de)

