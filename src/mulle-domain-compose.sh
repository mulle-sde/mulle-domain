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
MULLE_DOMAIN_COMPOSE_SH='included'



domain::compose::usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} compose [options] [domain]

   Create a dependency URL for a known domain and you generally will also
   need to specify a repository name at least. The known domains are listed
   on the bottom. You can use 'github' as the composition domain, but use
   the --host option tp specify a different, compatible server. You need
   to specify a domain! This domain changes the syntax of the emitted URL:

   Example:
      ${MULLE_USAGE_NAME} compose --host foobar.com \\
                                  --repo mulle-c11  \\
                                  --user mulle-c \\
                                  --tag latest \\
                                  github
   gives
      https://foobar.com/mulle-c/mulle-c11/archive/latest.tar.gz

   Use the --scm option to generate different URLs:

      homepage : https://foobar.com/mulle-c/mulle-c11
      none     : https://foobar.com/mulle-c/mulle-c11/tree/latest
      git      : https://foobar.com/mulle-c/mulle-c11.git
      zip      : https://foobar.com/mulle-c/mulle-c11/archive/latest.zip
      tar      : https://foobar.com/mulle-c/mulle-c11/archive/latest.tar.gz

   Note: "none" can be the same as "homepage", if there is no <tag>

Options:
   --domain <name>    : you can specify the required domain also as an option
   --host <name>      : specify a host like git.foobar.com
   --repo <repo>      : specify the reposiory required
   --scheme <scheme>  : specify a scheme (https)
   --scm <name>       : specify the SCM (tar)
   --tag <tag>        : specify a version tag (latest)
   --user <user>      : specify the owner, may be required
   -                  : read output from parse and transform into options

Domains:
EOF
   domain::plugin::list | sed 's/^/   /' >&2

   exit 1
}


#
# Use information from url if user/repo are not set. Use URL to determine
# plugin domain. (main difference to domain::plugin::r_compose_url)
# Used by resolve, not by compose_main.
#
domain::compose::r_compose_url()
{
   log_entry "domain::compose::r_compose_url" "$@"

   local url="$1"; shift

   local user="$1"
   local repo="$2"
   local tag="$3"
   local scm="$4"
   local scheme="$5"
   local host="$6"

   local domain

   if [ -z "$MULLE_DOMAIN_PARSE_SH" ]
   then
      # shellcheck source=mulle-domain-parse.sh
      . "${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-parse.sh" || \
         fail "failed to load ${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-parse.sh"
   fi

   domain::parse::r_url_get_domain "${url}"
   domain="${RVAL:-generic}"

   if [ -z "${user}" -o -z "${repo}" ]
   then
      local _scheme
      local _user
      local _repo
      local _tag
      local _scm

      domain::plugin::parse_url "${domain}" "${url}" || exit 1

      user="${user:-${_user}}"
      repo="${repo:-${_repo}}"
   fi

   if [ "${MULLE_FLAG_LOG_SETTINGS}" = 'YES' ]
   then
      log_setting "url    : ${url}"
      log_setting "domain : ${domain}"
      log_setting "user   : ${user}"
      log_setting "repo   : ${repo}"
      log_setting "tag    : ${tag}"
      log_setting "scm    : ${scm}"
      log_setting "scheme : ${scheme}"
      log_setting "host   : ${host}"
   fi

   domain::plugin::r_compose_url "${domain}" \
                        "${user}" "${repo}" "${tag}" "${scm}" "${scheme}" "${host}"
}


domain::compose::main()
{
   log_entry "domain::compose::main" "$@"

   local OPTION_USER
   local OPTION_REPO="whatever"
   local OPTION_SCHEME
   local OPTION_BRANCH
   local OPTION_DOMAIN
   local OPTION_TAG
   local OPTION_HOST
   local OPTION_SCM

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            domain::compose::usage
         ;;

         --branch)
            [ $# -eq 1 ] && domain::compose::usage "Missing argument to \"$1\""
            shift

            OPTION_BRANCH="$1"
         ;;

         --domain)
            [ $# -eq 1 ] && domain::compose::usage "Missing argument to \"$1\""
            shift

            OPTION_DOMAIN="$1"
         ;;

         --host)
            [ $# -eq 1 ] && domain::compose::usage "Missing argument to \"$1\""
            shift

            OPTION_HOST="$1"
         ;;

         --repo)
            [ $# -eq 1 ] && domain::compose::usage "Missing argument to \"$1\""
            shift

            OPTION_REPO="$1"
         ;;

         --scheme)
            [ $# -eq 1 ] && domain::compose::usage "Missing argument to \"$1\""
            shift

            OPTION_SCHEME="$1"
         ;;

         --scm)
            [ $# -eq 1 ] && domain::compose::usage "Missing argument to \"$1\""
            shift

            OPTION_SCM="$1"
         ;;

         --tag)
            [ $# -eq 1 ] && domain::compose::usage "Missing argument to \"$1\""
            shift

            OPTION_TAG="$1"
         ;;

         --user)
            [ $# -eq 1 ] && domain::compose::usage "Missing argument to \"$1\""
            shift

            OPTION_USER="$1"
         ;;

         -)
            text=`sed -e 's/^domain=/OPTION_DOMAIN=/' \
                      -e 's/^user=/OPTION_USER=/' \
                      -e 's/^repo=/OPTION_REPO=/' \
                      -e 's/^tag=/OPTION_TAG=/' \
                      -e 's/^branch=/OPTION_BRANCH=/' \
                      -e 's/^scm=/OPTION_SCM=/' \
                      -e 's/^scheme=/OPTION_SCHEME=/' \
                      -e 's/^host=/OPTION_HOST=/' ` || exit 1
            eval "$text"
         ;;

         -*)
            domain::compose::usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local domain

   if [ ! -z "${OPTION_DOMAIN}" ]
   then
      [ $# -ne 0 ] && domain::compose::usage "Superflous arguments $*"
      domain="${OPTION_DOMAIN}"
   else
      [ $# -eq 0 ] && domain::compose::usage "Missing domain argument"
      [ $# -gt 1 ] && shift && domain::compose::usage "Superflous arguments $*"

      domain="$1"
      shift
   fi

   if [ -z "${OPTION_SCM}" ]
   then
      case "${OPTION_USER}" in 
         mulle*|Mulle*)
            OPTION_SCM="tar"
            OPTION_TAG="${OPTION_TAG:-latest}"
         ;;

         ""|*)
            OPTION_SCM="git"
         ;;
      esac
   fi

   if ! domain::plugin::r_compose_url "${domain}" \
                                      "${OPTION_USER}" \
                                      "${OPTION_REPO}" \
                                      "${OPTION_TAG}" \
                                      "${OPTION_SCM}" \
                                      "${OPTION_SCHEME}" \
                                      "${OPTION_HOST}"
   then
      return 2
   fi

   if [ ! -z "${OPTION_BRANCH}" ]
   then
      RVAL="${RVAL}##${OPTION_BRANCH}"
   fi
   log_debug "Composed URL: ${url}"
   printf "%s\\n" "${RVAL}"
}


domain_compose_init()
{
   if [ -z "$MULLE_DOMAIN_PLUGIN_SH" ]
   then
      # shellcheck source=mulle-domain-plugin.sh
      . "${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-plugin.sh" || \
         fail "failed to load ${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-plugin.sh"
   fi
}

domain_compose_init

:
