#! /usr/bin/env bash
#
#   Copyright (c) 2020 Nat! - Mulle kybernetiK
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
MULLE_DOMAIN_PLUGIN_GITLAB_SH="included"


domain::plugin::gitlab::curl_json()
{
   log_entry "domain::plugin::gitlab::curl_json" "$@"

   local url="$1"

   CURL="${CURL:-`command -v curl`}"
   if [ -z "${CURL}" ]
   then
      fail "curl is required to access gitlab API"
      return $?
   fi

   local cmdline

   cmdline="'${CURL}'"
   if [ "${MULLE_FLAG_LOG_VERBOSE}" = 'YES' ]
   then
      cmdline="${cmdline} -fSL"
   else
      cmdline="${cmdline} -fsSL"
   fi

   cmdline="${cmdline} -H 'Content-Type: application/json'"
   if [ ! -z "${MULLE_DOMAIN_GITLAB_TOKEN}" ]
   then
      cmdline="${cmdline} -H 'PRIVATE-TOKEN: ${MULLE_DOMAIN_GITLAB_TOKEN}'"
   fi

   local quote
   local arg

   quote="'"
   for arg in "$@"
   do
      arg="${arg//${quote}/${quote}\"${quote}\"${quote}}"
      cmdline="${cmdline} '${arg}'"
   done

   eval_exekutor "${cmdline}"
}


domain::plugin::gitlab::tags_json()
{
   log_entry "domain::plugin::gitlab::tags_json" "$@"

   local user="$1"
   local repo="$2"

   [ -z "${user}" ] && _internal_fail "user is missing"
   [ -z "${repo}" ] && _internal_fail "repo is missing"

   if [ -z "${MULLE_DOMAIN_CURL_SH}" ]
   then
      # shellcheck source=mulle-domain-curl.sh
      . "${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-curl.sh" || \
         fail "failed to load ${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-curl.sh"
   fi

   local encoded_user
   local encoded_repo

   r_url_encode "${user}"
   encoded_user="${RVAL}"
   r_url_encode "${repo}"
   encoded_repo="${RVAL}"

   local url
   # "https://gitlab.com/api/v4/projects/fdroid%2Ffdroidclient/repository/tags"
   # if API changes default, we are covered because we are explicit ?
   url="https://gitlab.com/api/v4/projects/${encoded_user}%2F${encoded_repo}\
/repository/tags?order_by=updated&sort=desc"
   domain::plugin::gitlab::curl_json "${url}"
}


####
#### PLUGIN API
####

#
# parse URL into interesting constituent parts, currenly _user and _repo
#
# local _user
# local _repo
#
# https://gitlab.com/fdroid/artwork.git
# https://gitlab.com/fdroid/basebox/-/archive/0.5.1/basebox-0.5.1.zip
# https://gitlab.com/mulle-nat/test-project/-/archive/whatevs/test-project-whatevs.tar.gz
#
domain::plugin::gitlab::__parse_url()
{
   log_entry "domain::plugin::gitlab::__parse_url" "$@"

   local url="$1"

   [ -z "${url}" ] && _internal_fail "URL is empty"

   local s

   _scheme=""
   case "${url}" in
      *://*)
         _scheme="${url%://*}"
      ;;
   esac

   s="${url#*//}"       # remove scheme if any
   s="${s#*/}"          # remove domain (must be known already)

   _user="${s%%/*}"     # get user
   s="${s#${_user}/}"   # dial up to repo

   _repo="${s%%/*}"
   s="${s#${_repo}/}"   # checkout rest

   case "${_repo}" in
      *.git)
         _scm="git"
         _repo="${_repo%.git}"
         _tag=
         return
      ;;
   esac

   case "${s}" in
      */archive/*)
         s="${s#*/archive/}"   # s is now something like foo-latest.tar.gz maybe
         _tag="${s%%/*}"
         s="${s#${_tag}/}"

         r_url_remove_file_compression_extension "${s}"
         s="${RVAL}"

         _scm="${s##*.}"

         case "${_scm}" in
            'tgz')
               _scm='tar'
            ;;
         esac
      ;;

      *)
         _scm='git'
         _tag=
      ;;
   esac
}


#
# compose an URL from user repository name (repo), username (user)
# possibly a version (tag) and the desired SCM (git or tar usually)
#
# https://gitlab.com/mulle-nat/test-project/-/archive/whatevs/test-project-whatevs.tar.gz
#
domain::plugin::gitlab::r_compose_url()
{
   log_entry "domain::plugin::gitlab::r_compose_url" "$@"

   local user="$1"
   local repo="$2"
   local tag="$3"
   local scm="$4"
   local scheme="${5:-https}"
   local host="${6:-gitlab.com}"

   [ -z "${user}" ] && fail "User is required for gitlab URL"
   [ -z "${repo}" ] && fail "Repo is required for gitlab URL"


   repo="${repo%.git}"
   # could use API to get the URL, but laziness...
   case "${scm}" in
      git)
         r_concat "${scheme}://${host}/${user}/${repo}.git" "${tag}" '##'
      ;;

      tar)
         RVAL="${scheme}://${host}/${user}/${repo}/-/archive/${tag:-latest}/${repo}-${tag:-latest}.tar.gz"
      ;;

      zip)
         RVAL="${scheme}://${host}/${user}/${repo}/-/archive/${tag:-latest}/${repo}-${tag:-latest}.zip"
      ;;

      *)
         fail "Unsupported scm ${scm} for gitlab"
      ;;
   esac
}


#
# lists tag in one line, then commit in the next
#
domain::plugin::gitlab::tags_with_commits()
{
   log_entry "domain::plugin::gitlab::tags_with_commits" "$@"

   local user="$1"
   local repo="$2"

   JQ="`command -v "jq"`"
   if [ -z "${JQ}" ]
   then
      fail "jq is required for gitlab to parse the JSON"
      return $?
   fi

   # assume pipefail set
   domain::plugin::gitlab::tags_json "${user}" "${repo}" \
   | "${JQ}" '.[] | .name , .commit.id' \
   | sed 's/^"\(.*\)"$/\1/'
}
