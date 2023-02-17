## Plugins

mulle-domain has a plugin API, to manage multiple hosting domains such as
**github** or **gitlab**.


| Domain      | Supports            | Notes
|-------------|---------------------|-----------------------
| generic     | git, tar, zip       | Heuristic approach
| github      | tags, git, tar, zip | github API is severely rate-limited
| gitlab      | tags, git, tar, zip |
| sr          | tags, git, tar, zip |
| sourceforge | tar                 | Very barebones

With the help of the hosters public API and
[mulle-semver](//github.com/mulle-sde/mulle-semver), mulle-domain can resolve
[semver](https://docs.npmjs.com/cli/v6/using-npm/semver/) qualifiers like
`~2.0.0` to generate the proper archive URL to fetch.



