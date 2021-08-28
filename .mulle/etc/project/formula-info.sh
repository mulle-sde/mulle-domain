# -- Formula Info --
# If you don't have this file, there will be no homebrew
# formula operations.
#
PROJECT="mulle-domain"      # your project/repository name
DESC="🏰 URL management and tag resolution for repositories"
LANGUAGE="bash"                # c,cpp, objc, bash ...
# NAME="${PROJECT}"        # formula filename without .rb extension

DEPENDENCIES='${MULLE_SDE_TAP}mulle-semver'

#
DEBIAN_DEPENDENCIES="mulle-semver"
DEBIAN_RECOMMENDATIONS="curl"
