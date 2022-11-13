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
MULLE_DOMAIN_PARSE_SH="included"


domain::parse::usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} parse-url [options] <url>

   Parse a repository URL into constituent parts for known domains. This is
   not a general parser. If the domain is unknown, the result will be empty,
   when guessing is disabled. If the domain can not be guessed then the
   "generic" domain will be used to parse the URL.

   The parse values are returned as evaluatable bash assignments:

   Example:
      ${MULLE_USAGE_NAME} parse-url https://github.com/mulle-c/mulle-c11

   gives
      scheme=https
      domain=github
      scm=git
      user=mulle-c
      repo=mulle-c11
      branch=''
      tag=''

Options:
   --guess                    : guess domain from URL format (default)
   --no-guess                 : derive domain from URL host part
   --domain <domain>          : use domain instead of deriving it from URL
   --fallback-domain <domain> : use <domain>, if domain from URL is unguessable
   --no-fallback              : don't use a fallback if guessing fails

Domains:
EOF
   domain::plugin::list | sed 's/^/   /' >&2

   exit 1
}


domain::parse::r_url_guess_domain()
{
   local url="$1"

   local host
   local uri

   uri="${url#*://}"
   host="${uri%%/*}"

   case "${host}" in
      *.sr.ht|sr.ht)
         RVAL="sr"
         return 0
      ;;

      gitlab.*|*.gitlab.*)
         RVAL="gitlab"
         return 0
      ;;

      github.*|*.github.*)
         RVAL="github"
         return 0
      ;;
   esac

   case "${uri}" in
      # https://gitlab.freedesktop.org/freetype/freetype/-/archive/VER-2-10-4/freetype-VER-2-10-4.zip
      */*/*/-/archive/*/*\.zip|*/*/*/-/archive/*/*\.tar\.*|*/*/*/-/archive/*/*\.tar)
         RVAL="gitlab"
         return 0
      ;;

      # https://github.com/mulle-sde/github-ci/archive/v1.tar.gz
      */*/archive/*\.tar\.*|/*/archive/*\.tar|*/*/archive/*.zip)
         RVAL="generic"
         return 0
      ;;
   esac
   return 1
}


domain::parse::r_host_get_domain()
{
   #
   # remove foo.bar. from foo.bar.github.com
   #
   RVAL="$1"
   while :
   do
      case "${RVAL}" in
         *\.*\.*)
            RVAL="${RVAL#*\.}"
            continue
         ;;
      esac
      break
   done

   #
   # remove .com from github.com
   #
   RVAL="${RVAL%.*}"
}


domain::parse::r_url_get_domain()
{
   local url="$1"

   local host

   host="${url#*://}"
   host="${host%%/*}"

   domain::parse::r_host_get_domain "${host}"
}


domain::parse::r_url_get_domain_nofail()
{
   domain::parse::r_url_get_domain "$@"

   [ -z "${RVAL}" ] && fail "Couldn't get domain from URL ${url}"
}


#
# _domain:
# _scheme
# _user
# _repo
# _tag
# _scm
#
domain::parse::parse_url_domain()
{
   log_entry "domain::parse::parse_url_domain" "$@"

   local url="$1"
   local domain="$2"    # allow to parse random url with github parser

   domain::parse::r_url_get_domain "${url}"
   _domain="${RVAL}"

   local rval

   domain="${domain:-${_domain}}"
   domain="${domain:-generic}"

   domain::plugin::parse_url "${domain}" "${url}"
   rval=$?

   log_setting "scheme = '${_scheme}'"
   log_setting "domain = '${_domain}'"
   log_setting "scm    = '${_scm}'"
   log_setting "user   = '${_user}'"
   log_setting "repo   = '${_repo}'"
   log_setting "branch = '${_branch}'"
   log_setting "tag    = '${_tag}'"

   return $rval
}


domain::parse::main()
{
   log_entry "domain::parse::main" "$@"

   local OPTION_USER
   local OPTION_PREFIX
   local OPTION_REPO
   local OPTION_TAG
   local OPTION_GUESS='YES'
   local OPTION_SCM="tar"
   local OPTION_FALLBACK_DOMAIN="generic"

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            domain::parse::usage
         ;;

         --guess)
            OPTION_GUESS='YES'
         ;;

         --no-guess)
            OPTION_GUESS='NO'
         ;;

         --domain)
            [ $# -eq 1 ] && domain::parse::usage "Missing argument to \"$1\""
            shift

            OPTION_DOMAIN="$1"
         ;;

         --prefix)
            [ $# -eq 1 ] && domain::parse::usage "Missing argument to \"$1\""
            shift

            OPTION_PREFIX="$1"
         ;;

         --no-fallback)
            [ $# -eq 1 ] && domain::parse::usage "Missing argument to \"$1\""
            shift

            OPTION_FALLBACK_DOMAIN=""
         ;;

         --fallback-domain)
            [ $# -eq 1 ] && domain::parse::usage "Missing argument to \"$1\""
            shift

            OPTION_FALLBACK_DOMAIN="$1"
         ;;

         -*)
            domain::parse::usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -lt 1 ] && domain::parse::usage "missing arguments"
   [ $# -gt 1 ] && shift && domain::parse::usage "superflous arguments $*"

   local url="$1"

   local _scheme
   local _domain
   local _scm
   local _user
   local _repo
   local _branch
   local _tag

   case "${url}" in
      *##*)
         _branch="${url##*##}"
         url="${url%##*}"
      ;;
   esac

   local domain

   domain="${OPTION_DOMAIN}"
   if [ -z "${domain}" ]
   then
      if [ "${OPTION_GUESS}" = 'YES' ]
      then
         if domain::parse::r_url_guess_domain "${url}"
         then
            domain="${RVAL}"
            log_verbose "Guessed domain is \"${RVAL}\""
         fi
      fi

      if [ -z "${domain}" ]
      then
         domain::parse::r_url_get_domain "${url}"
         domain="${RVAL}"
         log_verbose "Derived domain as \"${domain}\""
      fi
   fi

   if [ -z "${domain}" ] || ! domain::plugin::load_if_needed "${domain}"
   then
      if [ -z "${OPTION_FALLBACK_DOMAIN}" ]
      then
         fail "Can't parse unkown domain \"${domain}\".
${C_INFO}Tip: Maybe use the --fallback-domain option ?"
      fi
      log_verbose "Using fallback domain \"${OPTION_FALLBACK_DOMAIN}\""
      domain="${OPTION_FALLBACK_DOMAIN}"
   fi

   #
   # make these only warnings, so we can turn them off in scripts
   #
   if ! domain::plugin::load_if_needed "${domain}"
   then
      log_warning "Can't parse unkown domain \"${domain}\""
      return 1
   fi

   if ! domain::parse::parse_url_domain "${url}" "${domain}"
   then
      log_warning "Could not parse URL for domain \"${domain}\""
      return 1
   fi

   if [ ! -z "${_tag}" ]
   then
      _branch=''
   fi

   #
   # we escape everything, because after all it can be evaluated,
   # empty string gets a '' though, so we have to check for that
   #
   printf -v _scheme "%q" "${_scheme}"
   printf -v _domain "%q" "${_domain}"
   printf -v _scm    "%q" "${_scm}"
   printf -v _user   "%q" "${_user}"
   printf -v _repo   "%q" "${_repo}"
   printf -v _branch "%q" "${_branch}"
   printf -v _tag    "%q" "${_tag}"

   cat <<EOF
${OPTION_PREFIX}scheme=${_scheme}
${OPTION_PREFIX}domain=${_domain}
${OPTION_PREFIX}scm=${_scm}
${OPTION_PREFIX}user=${_user}
${OPTION_PREFIX}repo=${_repo}
${OPTION_PREFIX}branch=${_branch}
${OPTION_PREFIX}tag=${_tag}
EOF
}


domain::parse::initalize()
{
   if [ -z "${MULLE_DOMAIN_PLUGIN_SH}" ]
   then
      # shellcheck source=mulle-domain-plugin.sh
      . "${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-plugin.sh" || exit 1
   fi
}

domain::parse::initalize

:
