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
MULLE_DOMAIN_PLUGIN_GITHUB_SH="included"


github_curl_json()
{
   log_entry "github_curl_json" "$@"

   local url="$1"

   local cmdline

   cmdline="'${CURL:-curl}'"
   if [ "${MULLE_FLAG_LOG_VERBOSE}" = 'YES' ]
   then
      cmdline="${cmdline} -fSL"
   else
      cmdline="${cmdline} -fsSL"
   fi

   cmdline="${cmdline} -H 'Accept: application/vnd.github.v3+json'"

   if [ ! -z "${MULLE_DOMAIN_GITHUB_TOKEN}" ]
   then
      cmdline="${cmdline} -H 'Authorization: token ${MULLE_DOMAIN_GITHUB_TOKEN}'"
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


#
# prefer empty array over empty string as return value
# two empty strings return an empty string
#
r_concat_json_arrays()
{
   local a="$1"
   local b="$2"

   if [ -z "${a}" ]
   then
      RVAL="${b}"
      return
   fi
   if [ -z "${b}" -o "${a//[$'\t\r\n' ]}" = '[]' ]
   then
      RVAL="${a}"
      return
   fi

   if [ "${b//[$'\t\r\n' ]}" = '[]' ]
   then
      RVAL="${a}"
      return
   fi

   local c

   a="`"${SED:-sed}" -e '$d' <<< "${a}" `" # remove ']'
   r_add_line "${a}" ","        # add ','
   c="${RVAL}"

   b="`"${SED:-sed}" -e '1d' <<< "${b}" `" # remove '['
   r_add_line "${c}" "${b}"      # add text
}


#
# lgrep json arrays from github. The resulting text string in RVAL is
# actually multiple JSON arrays concatenated
#
r_github_tags_json()
{
   log_entry "r_github_tags_json" "$@"

   local user="$1"
   local repo="$2"
   local maxpages="$3"
   local perpage=$4

   [ -z "${user}" ] && internal_fail "user is missing"
   [ -z "${repo}" ] && internal_fail "repo is missing"

   # the result is paginated, means we only get 30 tags and then have to
   # parse the next url from the response header. We can raise this to 100.
   #
   # https://docs.github.com/en/free-pro-team@latest/rest/guides/traversing-with-pagination
   #
   # Instead of parsing ther response header we run through the pages, until
   # we get nothing back. Costs us one extra curl call though
   #
   # MEMO: 22.3.2021 github is now pissy, and doesn't serve the second page
   # with tags. Is this because openssl has too many or is it because openssl
   # has maybe just reached 100 tags ? Nope it seems it just rate limits it
   # to death :(
   #
   local page
   local n
   local result
   local perpage

   page=1

   perpage="${perpage:-${MULLE_DOMAIN_GITHUB_PER_PAGE}}"
   perpage="${perpage:-100}"

   maxpages="${maxpages:-${MULLE_DOMAIN_GITHUB_MAX_PAGES}}"
   maxpages="${maxpages:-20}"

   while [ ${page} -le ${maxpages} ]
   do
      local url

      # say 1000, it don't matter
      url="https://api.github.com/repos/${user}/${repo}/tags?per_page=${perpage}&page=${page}"

      if ! text="`github_curl_json "${url}" `"
      then
         log_warning "Failed to fetch tags from github with \"${url}\".
${C_VERBOSE}Tip: Happens on github if you run into hourly limits.
Or maybe there are no tags (or no repo even :))."
         RVAL=
         return 1
      fi

      # check for empty [] if we are done, is easy but kills the rate limit
      # with two accesses,
      # if [ ${#text} -lt 20  ]
      # then
      #    break
      # fi

      r_concat_json_arrays "${result}" "${text}"
      result="${RVAL}"

      # assume it's an array of dictionaries, count opening '{'. A dict value
      # starts with  "key:" {  so they won't match.
      n="`"${EGREP:-egrep}" '^\ *{$' <<< "${text}" | wc -l `"
      log_debug "Received ${n## } of max ${perpage} tags"

      if [ $n -lt ${perpage} ]
      then
         break
      fi

      page=$((page + 1))
   done

   log_debug "JSON: ${result}"

   RVAL="${result}"
   return 0
}



####
#### PLUGIN API
####

#
# _scheme
# _user
# _repo
# _tag
# _scm
#
# https://github.com/mulle-sde/mulle-domain/archive/0.45.0.tar.gz
# https://github.com/mulle-sde/mulle-domain/archive/
#
domain_github_parse_url()
{
   log_entry "domain_github_parse_url" "$@"

   local url="$1"

   [ -z "${url}" ] && internal_fail "URL is empty"

   local s
   local before

#   local _scheme
   local _userinfo
   local _host
   local _port
   local _path
   local _query
   local _fragment

   url_parse "${url}"
   if [ -z "${_host}" ]
   then
      return 2
   fi

   _scheme="${_scheme%:}"
   s="${_path##/}"
   case "${s}" in
      */*)
      ;;

      *)
         return 2
      ;;
   esac

   _user="${s%%/*}"     # get user
   s="${s#${_user}/}"   # dial up to repo

   _repo="${s%%/*}"
   s="${s#${_repo}/}"   # checkout rest

   case "${s}" in
      archive/*)
         s="${s##*/}"        # checkout filename
         r_url_remove_file_compression_extension "${s}"
         s="${RVAL}"

         _scm="${s##*.}"
         case "${_scm}" in
            'tgz')
               _scm='tar'
            ;;
         esac

         _tag="${s%.${_scm}}"
      ;;

      *)
         _scm='git'
         _tag=
      ;;
   esac

   _repo="${_repo%.${_scm}}"
}



#
# compose an URL from user repository name (repo), username (user)
# possibly a version (tag) and the desired SCM (git or tar usually)
#
r_domain_github_compose_url()
{
   log_entry "r_domain_github_compose_url" "$@"

   local user="${1:-whoever}"
   local repo="$2"
   local tag="$3"
   local scm="$4"
   local scheme="${5:-https}"
   local host="${6:-github.com}"

   [ -z "${user}" ] && fail "User is required for github URL"
   [ -z "${repo}" ] && fail "Repo is required for github URL"

   repo="${repo%.git}"
   # could use API to get the URL, but laziness...
   case "${scm}" in
      git)
         r_concat "${scheme}://${host}/${user}/${repo}.git" "${tag}" '##'
      ;;

      tar)
         RVAL="${scheme}://${host}/${user}/${repo}/archive/${tag:-latest}.tar.gz"
      ;;

      zip)
         RVAL="${scheme}://${host}/${user}/${repo}/archive/${tag:-latest}.zip"
      ;;

      *)
         fail "Unsupported scm ${scm} for github"
      ;;
   esac
}


#
# lists tag in one line, then commit in the next
# hinges on the fact that github emits "name" first
# If it doesn't anymore reverse order with sed -n "{h;n;p;g;p}".
# If its now random, move to 'jq'
#
domain_github_tags_with_commits()
{
   log_entry "github_tags_with_commits" "$@"

   local user="$1"
   local repo="$2"

   if ! r_github_tags_json "${user}" "${repo}"
   then
      return 1
   fi
   "${EGREP:-egrep}" -e '^.*"name":|^.*"sha":'  <<< "${RVAL}" \
   | "${SED:-sed}" -e 's/^.*"[a-z]*": "\(.*\)".*$/\1/'
}


###
### Init
###
github_initialize()
{
   CURL="${CURL:-`command -v curl`}"
   if [ -z "${CURL}" ]
   then
      fail "curl is required to access github API"
      return $?
   fi

   SED="${SED:-`command -v sed`}"
   if [ -z "${SED}" ]
   then
      fail "sed is required to access github API"
      return $?
   fi

   EGREP="${EGREP:-`command -v egrep`}"
   if [ -z "${EGREP}" ]
   then
      fail "egrep is required to access github API"
      return $?
   fi

   if [ -z "${MULLE_URL_SH}" ]
   then
      # shellcheck source=../../../srcM/mulle-bashfunctions/src/mulle-url.sh
      . "${MULLE_BASHFUNCTIONS_LIBEXEC_DIR}/mulle-url.sh" || exit 1
   fi
}


github_initialize

:
