#! /usr/bin/env bash
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
MULLE_DOMAIN_RESOLVE_SH="included"



domain_resolve_usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} resolve <url> <qualifier>

   Use the semver <qualifier> to determine the correct tag to use for
   domaining a dependency from <url> for some known domains (e.g. github).
   As a shortcut, if the qualifier is just matching a single tag like "=2.1.1"
   or if the qualifier isn't a semver qualifier, it is used to construct
   the name of the tag (e.g. "latest" -> "latest")

   You provide an url like 'https://github.com/mulle-c/mulle-c11' and a
   semver qualifier like '>=3.1.0 <4.0.0' and "resolve" will locate the best
   matching archive URL on the host, which at the time of writing is:

   https://github.com/mulle-c/mulle-c11/archive/4.1.0.tar.gz

   mulle-domain has special treatment for a "latest" tag with the option
   --latest. Theh the qualifier must be a tag name only. If that tag exists, it
   will be matched. Otherwise the highest semver compatible tag is returned.

   See \`mulle-semver qualify help\` for more information about qualifiers.

Options:
   --scm <name>                   : URL kind to produce like tar, zip (git)
   --latest                       : use "latest" special functionality
   --resolve-single-tag           : match even if tag only matched one version
   --no-resolve-single-tag        : the opposite of --resolve-single-tag
EOF

   domain_plugin_list >&2
   exit 1
}




#
# grab tags from remote provider aka github, use qualifier to search for the
# best matching tag
#
r_resolve_semver_qualifier_to_tag()
{
   log_entry "r_resolve_semver_qualifier_to_tag" "$@"

   local qualifier="$1"
   local url="$2"

   local versions

   RVAL=
   versions="`domain_url_tags "${url}"`"
   [ $? -eq 1 ] && return 1
   if [ -z "${versions}" ]
   then
      return 2
   fi

   local extglob_memo

   shopt -q extglob
   extglob_memo=$?
   shopt -s extglob

   # YES=quiet
   r_semver_search "${qualifier}" "YES" "YES" "${versions}"
   rval=$?

   [ "${extglob_memo}" -ne 0 ] && shopt -u extglob
   return $rval
}


r_resolve_exact_match_tag()
{
   log_entry "r_resolve_exact_match_tag" "$@"

   local tag="$1"
   local url="$2"

   RVAL=
   if find_exact_match_tag "${url}" "${tag}"
   then
      RVAL="${tag}"
      return 0
   fi
   return 2
}


r_domain_resolve_qualifier_to_tag()
{
   log_entry "r_domain_resolve_qualifier_to_tag" "$@"

   local qualifier="$1"
   local url="$2"
   local resolve_single_tag="$3"

   if [ -z "${MULLE_SEMVER_SEARCH_SH}" ]
   then
      if [ -z "${MULLE_SEMVER_LIBEXEC_DIR}" ]
      then
         MULLE_SEMVER_LIBEXEC_DIR="`${MULLE_SEMVER:-mulle-semver} libexec-dir `" || exit 1
         export MULLE_SEMVER_LIBEXEC_DIR
      fi
      . "${MULLE_SEMVER_LIBEXEC_DIR}/mulle-semver-search.sh"
   fi

   r_semver_sanitized_qualifier "${qualifier}"
   qualifier="${RVAL}"

   local extglob_memo

   shopt -q extglob
   extglob_memo=$?
   shopt -s extglob

   local rval

   rval=0
   RVAL=

   _semver_qualifier_type "${qualifier}"
   rval=$?

   r_semver_qualifier_type_description $rval
   log_debug "Qualifier type: $RVAL"

   case $rval in
      ${semver_empty_qualifier})
         # need to resolve qualifier to a single tag
         if ! r_resolve_semver_qualifier_to_tag "*" "${url}"
         then
            rval=2
         fi
      ;;

      ${semver_no_qualifier})
         # could be a tag, but definitely not a semver qualifier
         RVAL="${qualifier}"
         if [ "${resolve_single_tag}" = 'YES' ]
         then
            if ! r_resolve_exact_match_tag "${qualifier}" "${url}"
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
            if ! r_resolve_semver_qualifier_to_tag "${qualifier}" "${url}"
            then
               rval=2
            fi
         fi
         RVAL="${qualifier#=}"
      ;;

      ${semver_multi_qualifier})
         # need to resolve qualifier to a single tag
         if ! r_resolve_semver_qualifier_to_tag "${qualifier}" "${url}"
         then
            rval=2
         fi
      ;;
   esac

   [ "${extglob_memo}" -ne 0 ] && shopt -u extglob

   return $rval
}


#
# 0 resolved
# 1 means don't have plugin to resolve
# 2 means could not resolve
#
domain_resolve_main()
{
   log_entry "domain_resolve_main" "$@"

   local OPTION_SCM="tar"
   local OPTION_RESOLVE_SINGLE_TAG='YES'
   local OPTION_EXACT='NO'

   if [ -z "$MULLE_DOMAIN_PLUGIN_SH" ]
   then
      # shellcheck source=mulle-domain-plugin.sh
      . "${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-plugin.sh" || \
         fail "failed to load ${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-plugin.sh"
   fi


   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            domain_resolve_usage
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
            [ $# -eq 1 ] && domain_resolve_usage "Missing argument to \"$1\""
            shift

            OPTION_SCM="$1"
         ;;

         -*)
            domain_resolve_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -lt 2 ] && log_error  && domain_typeguess_usage "missing argument"
   [ $# -gt 2 ] && shift 2 && domain_typeguess_usage "superflous arguments \"$*\""

   local url="$1"
   local qualifier="$2"

   local url
   local qualifier
   local tag

   RVAL=

   if [ "${OPTION_LATEST}" = 'YES' ]
   then
      find_exact_match_tag "${url}" "${qualifier}"
      rval=$?
      [ $rval -ne 0 ] && return $rval

      if [ $rval -eq 2 -a "${OPTION_LATEST}" = 'YES' ]
      then
         r_domain_resolve_qualifier_to_tag "*" "${url}"
         rval=$?

         [ $rval -ne 0 ] && return $rval
         tag="${RVAL}"
      fi
   else
      r_domain_resolve_qualifier_to_tag "${qualifier}" \
                                        "${url}" \
                                        "${OPTION_RESOLVE_SINGLE_TAG}"
      rval=$?
      case "${rval}" in
         0)
            tag="${RVAL}"
         ;;

         3)
            tag="${qualifier}"
         ;;

         *)
            return $rval
         ;;
      esac
   fi

   [ -z "${tag}" ] && internal_fail "empty tag returned"

   domain_compose_url_main --tag "${tag}" \
                           --scm "${OPTION_SCM}" \
                           "${url}" || exit 1

   return $rval
}


domain_parse_initalize()
{
   if [ -z "${MULLE_DOMAIN_COMANDS_SH}" ]
   then
      # shellcheck source=mulle-domain-commands.sh
      . "${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-commands.sh" || exit 1
   fi

   if [ -z "${MULLE_DOMAIN_COMPOSE_SH}" ]
   then
      # shellcheck source=mulle-domain-compose.sh
      . "${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-compose.sh" || exit 1
   fi
}

domain_parse_initalize

:
