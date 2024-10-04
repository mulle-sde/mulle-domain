# shellcheck shell=bash
#
#   Copyright (c) 2015-2017 Nat! - Mulle kybernetiK
#   All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions are met:
#
#   Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
#   Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
#   Neither the name of Mulle kybernetiK nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#
MULLE_DOMAIN_RESOLVE_SH='included'



domain::resolve::usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} resolve <url> <qualifier>

   Uses the semver <qualifier> to determine the correct tag to use for
   fetching a dependency from <url> for some known domains (e.g. github).

   You provide an url like 'https://github.com/mulle-c/mulle-c11' and a
   semver qualifier like '>=3.1.0 <4.0.0' and "resolve" will locate the best
   matching archive URL on the host, which at the time of writing is:

   https://github.com/mulle-c/mulle-c11/archive/4.1.0.tar.gz

   As a shortcut, if the qualifier can match only a single tag like "=2.1.1",
   it is used to construct the URL directly.

   mulle-domain has special treatment for a "latest" tag with the option
   --latest. The qualifier must then be a tag name only. If that tag exists, it
   will be matched. Otherwise the highest semver compatible tag is returned.

   See \`mulle-semver qualify help\` for more information about qualifiers.

Options:
   --domain <name>         : force use of a certain domain plugin (e.g. github)
   --latest                : use "latest" special functionality
   --no-resolve-single-tag : the opposite of --resolve-single-tag
   --resolve-single-tag    : match even if tag only matched one version
   --scm <name>            : URL kind to produce like tar, zip (git)

Domains:
EOF

   domain::plugin::list | sed 's/^/   /' >&2
   exit 1
}




#
# grab tags from remote provider aka github, use qualifier to search for the
# best matching tag
#
domain::resolve::r_semver_qualifier_to_tag()
{
   log_entry "domain::resolve::r_semver_qualifier_to_tag" "$@"

   local url="$1"
   local domain="$2"
   local qualifier="$3"
   local versions=$4

   local rval

   domain::commands::r_lazy_url_tags "${url}" "${domain}" "${versions}"
   rval=$?
   [ $rval -ne 0 ] && return $rval

   versions="${RVAL}"

   shell_is_extglob_enabled || _internal_fail "extglob must be enabled"
   # YES=quiet
   semver::search::search "${qualifier}" 'YES' 'YES' "${versions}"
}


domain::resolve::r_exact_match_tag()
{
   log_entry "domain::resolve::r_exact_match_tag" "$@"

   local url="$1"
   local domain="$2"
   local tag="$3"
   local versions="$4"

   RVAL=
   if domain::commands::find_exact_match_tag "${url}" "${domain}" "${tag}" "${versions}"
   then
      RVAL="${tag}"
      return 0
   fi
   return 2
}


domain::resolve::r_qualifier_to_tag()
{
   log_entry "domain::resolve::r_qualifier_to_tag" "$@"

   local url="$1"
   local domain="$2"
   local qualifier="$3"
   local resolve_single_tag="$4"
   local versions="$5"

   if [ -z "${MULLE_SEMVER_SEARCH_SH}" ]
   then
      if [ -z "${MULLE_SEMVER_LIBEXEC_DIR}" ]
      then
         MULLE_SEMVER_LIBEXEC_DIR="`${MULLE_SEMVER:-mulle-semver} libexec-dir `" || exit 1
         export MULLE_SEMVER_LIBEXEC_DIR
      fi
      . "${MULLE_SEMVER_LIBEXEC_DIR}/mulle-semver-search.sh"
   fi

   semver::qualify::sanitized_qualifier "${qualifier}"
   qualifier="${RVAL}"

   shell_is_extglob_enabled || _internal_fail "extglob must be enabled"

   local qualifier_type 

   semver::qualify::which_type "${qualifier}"
   qualifier_type=$?

   semver::qualify::r_type_description $qualifier_type
   log_debug "Qualifier type: $RVAL"

   local rval

   rval=0
   if [ ${ZSH_VERSION+x} ]
   then
      case $qualifier_type in
         ${~semver_empty_qualifier})
            # need to resolve qualifier to a single tag
            if ! domain::resolve::r_semver_qualifier_to_tag "${url}" \
                                                   "${domain}" \
                                                   "*" \
                                                   "${versions}"
            then
               rval=2
            fi
         ;;

         ${~semver_no_qualifier})
            # could be a tag, but definitely not a semver qualifier
            RVAL="${qualifier}"
            if [ "${resolve_single_tag}" = 'YES' ]
            then
               if ! domain::resolve::r_exact_match_tag "${url}" \
                                              "${domain}" \
                                              "${qualifier}" \
                                              "${versions}"
               then
                  rval=2
               fi
            else
               rval=3
            fi
         ;;

         ${~semver_semver_qualifier}|${~semver_single_qualifier})
            # we figured out the tag already
            if [ "${resolve_single_tag}" = 'YES' ]
            then
               if ! domain::resolve::r_semver_qualifier_to_tag "${url}" \
                                                      "${domain}" \
                                                      "${qualifier}" \
                                                      "${versions}"
               then
                  rval=2
               fi
            fi
            RVAL="${qualifier#=}"
         ;;

         ${~semver_multi_qualifier})
            # need to resolve qualifier to a single tag
            if ! domain::resolve::r_semver_qualifier_to_tag  "${url}" \
                                                    "${domain}" \
                                                    "${qualifier}" \
                                                    "${versions}"
            then
               rval=2
            fi
         ;;
      esac
   else
      case $qualifier_type in
         ${semver_empty_qualifier})
            # need to resolve qualifier to a single tag
            if ! domain::resolve::r_semver_qualifier_to_tag "${url}" \
                                                   "${domain}" \
                                                   "*" \
                                                   "${versions}"
            then
               rval=2
            fi
         ;;

         ${semver_no_qualifier})
            # could be a tag, but definitely not a semver qualifier
            RVAL="${qualifier}"
            if [ "${resolve_single_tag}" = 'YES' ]
            then
               if ! domain::resolve::r_exact_match_tag "${url}" \
                                              "${domain}" \
                                              "${qualifier}" \
                                              "${versions}"
               then
                  rval=2
               fi
            else
               rval=3
            fi
         ;;

         ${semver_semver_qualifier}|${semver_single_qualifier})
            # we figured out the tag already
            if [ "${resolve_single_tag}" = 'YES' ]
            then
               if ! domain::resolve::r_semver_qualifier_to_tag "${url}" \
                                                      "${domain}" \
                                                      "${qualifier}" \
                                                      "${versions}"
               then
                  rval=2
               fi
            fi
            RVAL="${qualifier#=}"
         ;;

         ${semver_multi_qualifier})
            # need to resolve qualifier to a single tag
            if ! domain::resolve::r_semver_qualifier_to_tag  "${url}" \
                                                    "${domain}" \
                                                    "${qualifier}" \
                                                    "${versions}"
            then
               rval=2
            fi
         ;;
      esac
   fi

   return $rval
}


domain::resolve::r_resolve_url()
{
   log_entry "domain::resolve::r_resolve_url" "$@"

   local url="$1"
   local qualifier="$2"
   local domain="$3"
   local scm="$4"
   local latest="$5"
   local resolve_single_tag="$6"

   local tag
   local versions

   RVAL=
   if [ "${latest}" = 'YES' ]
   then
      # avoid doing this twice, so do it ahead of _domain_find_exact_match_tag
      # and _r_domain_resolve_qualifier_to_tag
      domain::commands::r_lazy_url_tags "${url}" "${domain}"
      [ $? -eq 1 ] && return 1
      if [ -z "${RVAL}" ]
      then
         return 2
      fi
      versions="${RVAL}"

      domain::commands::find_exact_match_tag "${url}" \
                                             "${domain}" \
                                             "${qualifier}" \
                                             "${versions}"
      rval=$?

      case ${rval} in
         0)
            tag="${qualifier}"
         ;;

         2)
            domain::resolve::r_qualifier_to_tag "${url}" \
                                                "${domain}" \
                                                "*" \
                                                "${resolve_single_tag}" \
                                                "${versions}"
            rval=$?

            [ $rval -ne 0 ] && return $rval
            tag="${RVAL}"
         ;;

         *)
            return $rval
         ;;
      esac
   else
      domain::resolve::r_qualifier_to_tag "${url}" \
                                          "${domain}" \
                                          "${qualifier}" \
                                          "${resolve_single_tag}"
      rval=$?
      case "${rval}" in
         0)
            tag="${RVAL}"
         ;;

         3)
            tag="${qualifier}"
         ;;

         *)
            fail "Resolve failed ($rval)"
            return $rval
         ;;
      esac
   fi

   [ -z "${tag}" ] && _internal_fail "empty tag returned"

   if ! domain::compose::r_compose_url "${url}" "" "" "${tag}" "${scm}"
   then
      return 1
   fi

   return 0
}


#
# 0 resolved
# 1 means don't have plugin to resolve
# 2 means could not resolve
#
domain::resolve::main()
{
   log_entry "domain::resolve::main" "$@"

   local OPTION_SCM="tar"
   local OPTION_RESOLVE_SINGLE_TAG='YES'
   local OPTION_EXACT='NO'
   local OPTION_DOMAIN

   # shellcheck source=mulle-domain-plugin.sh
   include "domain::plugin"

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            domain::resolve::usage
         ;;

         --domain)
            [ $# -eq 1 ] && domain::resolve::usage "Missing argument to \"$1\""
            shift

            OPTION_DOMAIN="$1"
         ;;

         --latest)
            OPTION_EXACT='YES'
            OPTION_LATEST='YES'
         ;;

         --resolve-single-tag)
            OPTION_RESOLVE_SINGLE_TAG='YES'
         ;;

         --no-resolve-single-tag)
            OPTION_RESOLVE_SINGLE_TAG='NO'
         ;;

         --scm)
            [ $# -eq 1 ] && domain::resolve::usage "Missing argument to \"$1\""
            shift

            OPTION_SCM="$1"
         ;;

         -*)
            domain::resolve::usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -lt 2 ] && domain::resolve::usage "missing argument"
   [ $# -gt 2 ] && shift 2 && domain::resolve::usage "superfluous arguments \"$*\""

   local rc

   domain::resolve::r_resolve_url "$1" \
                                  "$2" \
                                  "${OPTION_DOMAIN}" \
                                  "${OPTION_SCM}" \
                                  "${OPTION_LATEST}" \
                                  "${OPTION_RESOLVE_SINGLE_TAG}"
   rc=$?
   if [ $rc -ne 0 ]
   then
      return $rc
   fi

   printf "%s\n" "${RVAL}"
}


domain::resolve::initalize()
{
   include "domain::commands"
   include "domain::compose"
}

domain::resolve::initalize

:
