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
MULLE_DOMAIN_PARSE_SH="included"


domain_parse_url_usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} parse-url [options] <url>

   Parse a repository URL into constituent parts for known domains. This is
   not a general parser. If the domain is unknown, the result will be empty.

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

Domains:
EOF
   domain_plugin_list | sed 's/^/   /' >&2

   exit 1
}


r_host_get_domain()
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


r_url_get_domain()
{
   local url="$1"

   local host

   host="${url#*://}"
   host="${host%%/*}"

   r_host_get_domain "${host}"
}



#
# _domain:
# _scheme
# _user
# _repo
# _tag
# _scm
#
domain_url_parse_url()
{
   log_entry "domain_url_parse_url" "$@"

   local url="$1"
   local domain="$2"    # allow to parse random url with github parser

   r_url_get_domain "${url}"
   _domain="${RVAL}"

   local rval

   domain="${domain:-${_domain}}"
   domain_parse_url "${domain}" "${url}"
   rval=$?

   if [ "${MULLE_FLAG_LOG_SETTINGS}" = 'YES' ]
   then
      log_trace2 "scheme = '${_scheme}'"
      log_trace2 "domain = '${_domain}'"
      log_trace2 "scm    = '${_scm}'"
      log_trace2 "user   = '${_user}'"
      log_trace2 "repo   = '${_repo}'"
      log_trace2 "branch = '${_branch}'"
      log_trace2 "tag    = '${_tag}'"
   fi

   return $rval
}


domain_parse_url_main()
{
   log_entry "domain_parse_url_main" "$@"

   local OPTION_USER
   local OPTION_REPO
   local OPTION_TAG
   local OPTION_SCM="tar"

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            domain_parse_url_usage
         ;;

         --domain)
            [ $# -eq 1 ] && domain_compose_url_usage "Missing argument to \"$1\""
            shift

            OPTION_DOMAIN="$1"
         ;;

         -*)
            domain_parse_url_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -lt 1 ] && domain_parse_url_usage "missing arguments"
   [ $# -gt 1 ] && shift && domain_parse_url_usage "superflous arguments $*"

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

   if ! domain_url_parse_url "${url}" "${OPTION_DOMAIN}"
   then
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
scheme=${_scheme}
domain=${_domain}
scm=${_scm}
user=${_user}
repo=${_repo}
branch=${_branch}
tag=${_tag}
EOF
}


domain_parse_initalize()
{
   if [ -z "${MULLE_DOMAIN_PLUGIN_SH}" ]
   then
      # shellcheck source=mulle-domain-plugin.sh
      . "${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-plugin.sh" || exit 1
   fi
}

domain_parse_initalize

:
