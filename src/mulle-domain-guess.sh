# shellcheck shell=bash
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
#   POSSIBILITY OF SUCH DAMAGE.
#

MULLE_DOMAIN_GUESS_SH='included'



domain::guess::nameguess_usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_EXECUTABLE_NAME} nameguess [options] <url>

   Guess the resulting name of the project specified by the URL.

      ${MULLE_EXECUTABLE_NAME} guess https://foo.com/bla.git?version=last

   returns "bla"

Options:
   -s <scm> : source type, either a repository or archive format (git)
EOF

   exit 1
}



domain::guess::typeguess_usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} typeguess [options]  <url>

   Guess the type of the repository provided by URL. If in doubt it returns
   nothing. Possible return values are "git", "svn", "tar", "zip", "clib". This
   guess is purely syntactical.

      ${MULLE_USAGE_NAME} typeguess https://foo.com/bla.git?version=last

   returns "git"
EOF
   exit 1
}



domain::guess::r_url_typeguess()
{
   log_entry "domain::guess::r_url_typeguess" "$@"

   local urlpath
   local compressed

   r_url_get_path "$@"
   urlpath="${RVAL}"

   tarcompressed='NO'

   # this works for gitlist
   case "${urlpath}" in
      */tarball/*)
         RVAL="tar"
         return
      ;;

      */zipball/*)
         RVAL="zip"
         return
      ;;
   esac

   if [ -d "$*" ]
   then
      RVAL="local"
      return
   fi

   while :
   do
      r_path_extension "${urlpath}"
      ext="${RVAL}"

      case "${ext}" in
         "gz"|"xz"|"bz2"|"bz")
            # remove known compression suffixes handled by tar
            tarcompressed='YES'
         ;;

         "tgz"|"tar")
            RVAL="tar"
            return
         ;;

         "git"|"svn"|"zip")
            if [ "${tarcompressed}" = 'YES' ]
            then
               return 1
            fi

            RVAL="$ext"
            return
         ;;

         *)
            case "$1" in
               *:*)
                  RVAL="git"
                  return 0
               ;;

               "")
                  return 1
               ;;

               */*|~*|.*)
                  RVAL="local"
                  return 0
               ;;

               *)
                  RVAL="none"
                  return
               ;;
            esac
         ;;
      esac

      r_extensionless_basename "${urlpath}"
      urlpath="${RVAL}"
   done
}



domain::guess::typeguess_main()
{
   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            domain::guess::typeguess_usage
         ;;

         -*)
            log_error "${MULLE_EXECUTABLE_FAIL_PREFIX}: Unknown option \"$1\""
            ${USAGE}
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local url

   [ $# -eq 0 ] && domain::guess::typeguess_usage "missing argument"
   [ $# -gt 1 ] && shift && domain::guess::typeguess_usage "superfluous arguments \"$*\""

   url="$1"
   [ -z "${url}" ] && fail "empty url"

   local _scheme
   local _domain
   local _scm
   local _user
   local _repo
   local _branch
   local _tag

   if domain::parse::parse_url_domain "${url}" && [ ! -z "${_scm}" ]
   then
      printf "%s\n" "${_scm}"
      return
   fi

   if domain::parse::parse_url_domain "${url}" "generic" && [ ! -z "${_scm}" ]
   then
      printf "%s\n" "${_scm}"
      return
   fi

   if ! domain::guess::r_url_typeguess "${url}"
   then
      return 1
   fi

   printf "%s\n" "${RVAL}"
}



domain::guess::nameguess_main()
{
   log_entry "domain::guess::nameguess_main" "$@"

   local OPTION_SCM

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            domain::guess::nameguess_usage
         ;;

         -s|--scm)
            [ $# -eq 1 ] && fail "Missing argument to \"$1\""
            shift

            OPTION_SCM="$1"
         ;;

         -*)
            log_error "${MULLE_EXECUTABLE_FAIL_PREFIX}: Unknown option \"$1\""
            ${USAGE}
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -eq 0 ] && domain::guess::nameguess_usage "missing argument"
   [ $# -gt 1 ] && shift && domain::guess::nameguess_usage "superfluous arguments \"$*\""

   local url="$1"             # URL of the clone

   case "${OPTION_SCM:-tar}" in
      git|tar|zip)
         local _scheme
         local _domain
         local _scm
         local _user
         local _repo
         local _branch
         local _tag

         if domain::parse::parse_url_domain "${url}" && [ ! -z "${_repo}" ]
         then
            printf "%s\n" "${_repo}"
            return
         fi

         if domain::parse::parse_url_domain "${url}" "generic" && [ ! -z "${_repo}" ]
         then
            printf "%s\n" "${_repo}"
            return
         fi

         r_url_get_path "${url}"
         r_basename "${RVAL}"

         local before

         while :
         do
            before="${RVAL}"
            # remove compression extensions
            RVAL="${RVAL%.7z}"
            RVAL="${RVAL%.bz2}"
            RVAL="${RVAL%.gz}"
            RVAL="${RVAL%.tar}"
            RVAL="${RVAL%.tgz}"
            RVAL="${RVAL%.xz}"
            RVAL="${RVAL%.zip}"

            if [ "${before}" = "${RVAL}" ]
            then
               break
            fi
         done

         RVAL="${RVAL%.${_scm:-${OPTION_SCM:-tar}}}"
      ;;

      *)
         r_basename "${url}"
      ;;
   esac

   printf "%s\n" "${RVAL}"
}


domain::guess::initalize()
{
   include "domain::parse"
   include "url"
   include "string"
   include "path"
}

domain::guess::initalize

:
