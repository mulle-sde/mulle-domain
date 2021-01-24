#! /usr/bin/env bash
#
#   Copyright (c) 2015 Nat! - Mulle kybernetiK
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
MULLE_DOMAIN_COMMANDS_SH="included"




print_tip_usage()
{
   cat <<EOF
Tip:
   If there is a public API available for this domain, you don't need an access
   token. But the GitHub API for example is limited to 60 requests per hours
   for unauthenticated users!

EOF
}


print_option_usage()
{
   cat <<EOF >&2
Options:
   -h                              : this help

EOF
}


print_option_usage()
{
   cat <<EOF >&2
Options:
   -h                              : this help
   --all                           : all tags

EOF
}



print_environment_usage()
{
   cat <<EOF
Environment:
   MULLE_DOMAIN_<domain>_TOKEN     : access token to use, domain in uppercase
   MULLE_DOMAIN_<domain>_MAX_PAGES : max pages to domain (20)
   MULLE_DOMAIN_<domain>_PER_PAGE  : number of entries per page up to 100 (100)
EOF
}


domain_tags_usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tags [options]

   List available tags. By default will only list semantic version (semver)
   compatible tags.

Example:
   ${MULLE_USAGE_NAME} tags --all https://github.com/MulleWeb/mulle-scion
EOF

   print_tip_usage >&2
   print_option2_usage >&2
   print_environment_usage >&2

   exit 1
}


domain_commit_for_tag_usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} commit-for-tag <url> <tag>

   Find the commit identifier for the given tag.

Examples:
   ${MULLE_USAGE_NAME} commit-for-tag \\
                           https://github.com/mulle-c/mulle-allocator \\
                           latest

EOF

   print_tip_usage >&2
   print_option_usage >&2
   print_environment_usage >&2

   exit 1
}



domain_tag_aliases_usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tag-aliases [options] <tag>

   Find tags that reference the same commit. By default will only list
   semantic version (semver) compatible tags.

Examples:
   ${MULLE_USAGE_NAME} tag-aliases \\
                           https://github.com/mulle-c/mulle-allocator \\
                           latest
EOF

   print_tip_usage >&2
   print_option_usage >&2
   print_environment_usage >&2

   exit 1
}



domain_tags_for_commit_usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tags-for-commit [options] <commit>

   List all tags for a given the commit identifier. By default will only list
   semantic version (semver) compatible tags. The commit identifier can not
   be shortened.

Examples:
   ${MULLE_USAGE_NAME} tags-for-commit \\
                           https://github.com/mulle-c/mulle-allocator \\
                           "c0209081acf014904c7514714f6e75b6a63b0dc0"
EOF
   print_tip_usage >&2
   print_option2_usage >&2
   print_environment_usage >&2

   exit 1
}


domain_tags_with_commits_usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tags [options]

   List available tags with their commits. This will always list all tags
   and not filter for semantic version tags.

Examples:
   ${MULLE_USAGE_NAME} tags-with-commits https://github.com/MulleWeb/mulle-sion

EOF

   print_tip_usage >&2
   print_option_usage >&2
   print_environment_usage >&2

   exit 1
}



domain_get_tag_aliases_usage()
{
   cat <<EOF >&2
Usage:
   ${MULLE_EXECUTABLE_NAME} tags-aliases [options] <url> <tag>

   List other tags that share the same commit as <tag<

      ${MULLE_EXECUTABLE_NAME} tags-aliases https://foo.com/bla.git latest

EOF

   print_tip_usage >&2
   print_option_usage >&2
   print_environment_usage >&2

   exit 1
}



##
## Conveniences for above API based on known domain
##


#
# Used to find the matching numeric tag for "latest"
#
domain_commit_for_tag()
{
   log_entry "domain_commit_for_tag" "$@"

   local domain="$1"
   local user="$2"
   local repo="$3"
   local tag="$4"

   [ -z "${tag}" ] && internal_fail "tag is missing"

   local pattern

   r_escaped_sed_pattern "${tag}"
   pattern="${RVAL}"

   domain_tags_with_commits "${domain}" "${user}" "${repo}" \
   | sed -n "/^${pattern}\$/{n;p}"
}


domain_tags_for_commit()
{
   log_entry "domain_tags_for_commit" "$@"

   local domain="$1"
   local user="$2"
   local repo="$3"
   local commit="$4"

   local pattern

   r_escaped_sed_pattern "${commit}"
   pattern="${RVAL}"

   domain_tags_with_commits "${domain}" "${user}" "${repo}" \
   | sed -n "{h;n;p;g;p}" \
   | sed -n "/^${pattern}\$/{n;p}"
}


#
# i use this often and don't want to hit the API twice so...
#
domain_get_tag_aliases()
{
   log_entry "domain_get_tag_aliases" "$@"

   local domain="$1"
   local user="$2"
   local repo="$3"
   local tag="$4"

   local tag_pattern

   r_escaped_sed_pattern "${tag}"
   tag_pattern="${RVAL}"

   local list

   list="`domain_tags_with_commits "${domain}" "${user}" "${repo}" `" || exit 1
   commit="`sed -n "/^${tag_pattern}\$/{n;p}" <<< "${list}" `"

   [ -z "${commit}" ] && return 0 # no return values here

   local commit_pattern

   r_escaped_sed_pattern "${commit}"
   commit_pattern="${RVAL}"

   # flip list, find commit, remove tag from list
   sed -n "{h;n;p;g;p}" <<< "${list}" \
   | sed -n -e "/^${commit_pattern}\$/{n;p}"  \
   | sed -e "/^${tag_pattern}\$/d"
}


##
## Conveniences for above API based on known url
##

#
# returns values in
#
# local _user
# local _repo
#

domain_url_tags()
{
   log_entry "domain_url_tags" "$@"

   local url="$1"

   local domain

   r_url_get_domain "${url}"
   domain="${RVAL}"

   local _user
   local _repo

   domain_parse_url "${domain}" "${url}"
   domain_tags_with_commits "${domain}" "${_user}" "${_repo}" \
   |  sed -n "{h;n;g;p}"
}


domain_url_tags_for_commit()
{
   log_entry "domain_url_tags_for_commit" "$@"

   local url="$1"

   local domain

   r_url_get_domain "${url}"
   domain="${RVAL}"

   local _user
   local _repo

   domain_parse_url "${domain}" "${url}"
   domain_tags_for_commit "${domain}" "${_user}" "${_repo}"
}



##
## Conveniences for above API
##
r_domain_most_recent_tag()
{
   log_entry "r_domain_most_recent_tag" "$@"

   local url="$1"

   RVAL=
   versions="`domain_url_tags "${url}"`"
   [ $? -eq 1 ] && return 1
   if [ -z "${versions}" ]
   then
      return 2
   fi

   # get head
   IFS=$'\n' read RVAL <<< "${versions}"
   return $rval
}


find_exact_match_tag()
{
   log_entry "find_exact_match_tag" "$@"

   local url="$1"
   local tag="$2"

   local versions
   local version

   RVAL=
   versions="`domain_url_tags "${url}"`"
   [ $? -eq 1 ] && return 1
   if [ -z "${versions}" ]
   then
      return 2
   fi

   IFS=$'\n'; set -f
   for version in ${versions}
   do
      if [ "${version}" = "${tag}" ]
      then
         IFS="${DEFAULT_IFS}";  set +f
         return 0
      fi
   done
   IFS="${DEFAULT_IFS}";  set +f
   return 2
}



#### COMMANDLINE INTERFACE
domain_include_semver_parse()
{
   if [ -z "${MULLE_SEMVER_PARSE_SH}" ]
   then
      if [ -z "${MULLE_SEMVER_LIBEXEC_DIR}" ]
      then
         MULLE_SEMVER_LIBEXEC_DIR="`${MULLE_SEMVER:-mulle-semver} libexec-dir `" || exit 1
         export MULLE_SEMVER_LIBEXEC_DIR
      fi
      . "${MULLE_SEMVER_LIBEXEC_DIR}/mulle-semver-parse.sh"
   fi
}


r_domain_filter_semver_tags()
{
   log_entry "r_domain_filter_semver_tags" "$@"

   local tags="$1"

   domain_include_semver_parse

   local memo

   shopt -q extglob
   memo=$?
   shopt -s extglob

   r_semver_parse_versions "${tags}" 'YES' 'YES'
   r_semver_parsed_versions_decriptions "${RVAL}"

   [ "${memo}" -ne 0 ] && shopt -u extglob
}



r_domain_filter_semver_tags_and_commits()
{
   log_entry "r_domain_filter_semver_tags_and_commits" "$@"

   local tags="$1"

   domain_include_semver_parse

   local memo

   shopt -q extglob
   memo=$?
   shopt -s extglob

   local result
   local tag
   local commit

   IFS=$'\n'
   while :
   do
      if ! read tag
      then
         break
      fi
      if ! read commit
      then
         break
      fi

      local _line
      local _build
      local _prerelease
      local _major
      local _minor
      local _patch

      if ! semver_parse "${tag}" 'YES'
      then
         continue
      fi

      r_add_line "${result}" "${tag}"
      r_add_line "${RVAL}" "${commit}"
      result="${RVAL}"
   done <<< "${text}"
   IFS="${DEFAULT_IFS}"

   [ "${memo}" -ne 0 ] && shopt -u extglob

   RVAL="${result}"
}


##
## CLI Interface
##

domain_common_option_shifts()
{
   case "$1" in
      --user)
         [ $# -eq 1 ] && fail "Missing argument to \"$1\""
         shift

         OPTION_USER="$1"
         return 2
      ;;

      --repo)
         [ $# -eq 1 ] && fail "Missing argument to \"$1\""
         shift

         OPTION_REPO="$1"
         return 2
      ;;

      --token|--domain-token)
         [ $# -eq 1 ] && fail "Missing argument to \"$1\""
         shift

         OPTION_TOKEN="$1"
         return 2
      ;;

      --per-page)
         [ $# -eq 1 ] && fail "Missing argument to \"$1\""
         shift

         OPTION_PER_PAGE="$1"
         [ "${OPTION_PER_PAGE}" -lt 1 ] && fail "Invalid number of entries"
         if [ "${OPTION_PER_PAGE}" -gt 100 ]
         then
            log_warning "Warning: more than 100 entries per page is unlikely to work"
         fi
         return 2
      ;;

      --max-pages)
         [ $# -eq 1 ] && fail "Missing argument to \"$1\""
         shift

         OPTION_MAX_PAGES="$1"
         [ "${OPTION_MAX_PAGES}" -lt 1 ] && fail "Invalid number of pages"
         return 2
      ;;
   esac

   return 0
}


#
# local _domain
# local _user
# local _repo
#
domain_common_url_domain_parse()
{
   local url_domain="$1"
   local user="$2"
   local repo="$3"

   case "${url_domain}" in
      *:*)
         log_debug "${url_domain} is a url"

         url="${url_domain}"
         if ! r_url_get_domain "${url}"
         then
            domain_domain_usage "Unparsable url"
         fi
         _domain="${RVAL}"

         if ! domain_parse_url "${_domain}" "${url}"
         then
            fail "Can't parse URL for user/repo"
         fi
      ;;

      *)
         log_debug "${url_domain} is a domain"

         _domain="${url_domain}"
         _user="${user}"
         _repo="${repo}"
      ;;
   esac

   [ -z "${_user}" ] && fail "Specify user with --user <name>"
   [ -z "${_repo}" ] && fail "Specify repo with --repo <name>"

   local domain_identifier_upcase

   r_identifier "${_domain}"
   r_uppercase "${_domain}"
   domain_identifier_upcase="${RVAL}"

   if [ ! -z "${OPTION_TOKEN}" ]
   then
      MULLE_DOMAIN_${domain_identifier_upcase}_TOKEN="${OPTION_TOKEN}"
   fi
   if [ ! -z "${OPTION_PER_PAGE}" ]
   then
      MULLE_DOMAIN_${domain_identifier_upcase}_PER_PAGE="${OPTION_PER_PAGE}"
   fi
   if [ ! -z "${OPTION_MAX_PAGES}" ]
   then
      MULLE_DOMAIN_${domain_identifier_upcase}_MAX_PAGES="${OPTION_MAX_PAGES}"
   fi
}



domain_tags_with_commits_main()
{
   log_entry "domain_tags_with_commits_main" "$@"

   while [ $# -ne 0 ]
   do
      domain_common_option_shifts "$@"
      shifts=$?

      if [ $shifts -ne 0 ]
      then
         shift $shifts
         continue
      fi

      case "$1" in
         -h*|--help|help)
            domain_tags_with_commits_usage
         ;;

         -*)
            domain_tags_with_commits_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -eq 0 ] && domain_tags_with_commits_usage "missing argument"
   [ $# -gt 1 ] && shift && domain_tags_with_commits_usage "superflous arguments \"$*\""

   local url_domain="$1"

   local _domain
   local _user
   local _repo

   domain_common_url_domain_parse "${url_domain}" "${OPTION_USER}" "${OPTION_REPO}"

   if [ "${OPTION_SEMVER}" = 'NO' ]
   then
      tags_with_commits "${_domain}" "${_user}" "${_repo}" "$@"
      return $?
   fi

   local text

   text="`domain_tags_with_commits "${_domain}" "${_user}" "${_repo}" "$@" `"
   r_domain_filter_semver_tags_and_commits "${text}"

   [ -z "${RVAL}" ] && return 1

   printf "%s\n" "${RVAL}"
}


domain_commit_for_tag_main()
{
   log_entry "domain_commit_for_tag_main" "$@"

   while [ $# -ne 0 ]
   do
      domain_common_option_shifts "$@"
      shifts=$?

      if [ $shifts -ne 0 ]
      then
         shift $shifts
         continue
      fi

      case "$1" in
         -h*|--help|help)
            domain_commit_for_tag_usage
         ;;

         -*)
            domain_commit_for_tag_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -lt 2 ] && domain_get_tag_aliases_usage "missing argument"
   [ $# -gt 2 ] && shift 2 && domain_get_tag_aliases_usage "superflous arguments \"$*\""

   local url_domain="$1"
   local tag="$2"

   local _domain
   local _user
   local _repo

   domain_common_url_domain_parse "${url_domain}" "${OPTION_USER}" "${OPTION_REPO}"

   domain_commit_for_tag "${_domain}" "${_user}" "${_repo}" "${tag}"
}


domain_tags_for_commit_main()
{
   log_entry "domain_tags_for_commit_main" "$@"

   local OPTION_SEMVER='NO'

   while [ $# -ne 0 ]
   do
      domain_common_option_shifts "$@"
      shifts=$?

      if [ $shifts -ne 0 ]
      then
         shift $shifts
         continue
      fi

      case "$1" in
         -h*|--help|help)
            domain_tags_for_commit_usage
         ;;

         --all)
            OPTION_SEMVER='NO'
         ;;

         -*)
            domain_tags_for_commit_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -lt 2 ] && domain_get_tag_aliases_usage "missing argument"
   [ $# -gt 2 ] && shift 2 && domain_get_tag_aliases_usage "superflous arguments \"$*\""

   local url_domain="$1"
   local commit="$2"

   local _domain
   local _user
   local _repo

   domain_common_url_domain_parse "${url_domain}" "${OPTION_USER}" "${OPTION_REPO}"

   domain_tags_for_commit "${_domain}" "${_user}" "${_repo}" "${commit}"
}


domain_get_tag_aliases_main()
{
   log_entry "domain_get_tag_aliases_main" "$@"

   local OPTION_SEMVER='NO'

   while [ $# -ne 0 ]
   do
      domain_common_option_shifts "$@"
      shifts=$?

      if [ $shifts -ne 0 ]
      then
         shift $shifts
         continue
      fi

      case "$1" in
         -h*|--help|help)
            domain_get_tag_aliases_usage
         ;;

         --all)
            OPTION_SEMVER='NO'
         ;;

         -*)
            domain_get_tag_aliases_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -lt 2 ] && domain_get_tag_aliases_usage "missing argument"
   [ $# -gt 2 ] && shift 2 && domain_get_tag_aliases_usage "superflous arguments \"$*\""

   local url_domain="$1"
   local tag="$2"

   local _domain
   local _user
   local _repo

   domain_common_url_domain_parse "${url_domain}" "${OPTION_USER}" "${OPTION_REPO}"

   domain_get_tag_aliases "${_domain}" "${_user}" "${_repo}" "${tag}"
}


domain_tags_main()
{
   log_entry "domain_tags_main" "$@"

   local OPTION_SCM="tar"
   local OPTION_SEMVER='YES'

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            domain_tags_usage
         ;;

         --all)
            OPTION_SEMVER='NO'
         ;;

         -*)
            domain_tags_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -eq 0 ] && domain_tags_usage "missing argument"
   [ $# -gt 1 ] && shift && domain_tags_usage "superflous arguments \"$*\""

   local url

   url="$1"

   versions="`domain_url_tags "${url}"`"

   if [ "${OPTION_SEMVER}" = 'YES' ]
   then
      if [ -z "${MULLE_SEMVER_PARSE_SH}" ]
      then
         if [ -z "${MULLE_SEMVER_LIBEXEC_DIR}" ]
         then
            MULLE_SEMVER_LIBEXEC_DIR="`${MULLE_SEMVER:-mulle-semver} libexec-dir `" || exit 1
            export MULLE_SEMVER_LIBEXEC_DIR
         fi
         . "${MULLE_SEMVER_LIBEXEC_DIR}/mulle-semver-parse.sh"
      fi

      local memo

      shopt -q extglob
      memo=$?
      shopt -s extglob

      r_semver_parse_versions "${versions}" 'YES' 'YES'
      r_semver_parsed_versions_decriptions "${RVAL}"
      versions="${RVAL}"

      [ "${memo}" -ne 0 ] && shopt -u extglob
   fi

   if [ -z "${versions}" ]
   then
      return 1
   fi
   printf "%s\n" "${versions}"
}


domain_commands_initialize()
{
   if [ -z "$MULLE_DOMAIN_PLUGIN_SH" ]
   then
      # shellcheck source=mulle-domain-plugin.sh
      . "${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-plugin.sh" || \
         fail "failed to load ${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-plugin.sh"
   fi
   if [ -z "$MULLE_DOMAIN_PARSE_SH" ]
   then
      # shellcheck source=mulle-domain-parse.sh
      . "${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-parse.sh" || \
         fail "failed to load ${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-parse.sh"
   fi
}

domain_commands_initialize

:

