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
MULLE_DOMAIN_PLUGIN_SR_SH='included'


# totally experimental

domain::plugin::sr::curl_html()
{
   log_entry "domain::plugin::sr::curl_html" "$@"

   local url="$1"

   CURL="${CURL:-`command -v curl`}"
   if [ -z "${CURL}" ]
   then
      fail "curl is required to access sr API"
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


domain::plugin::sr::scrape()
{
   sed -n "/<div class=\"event\">/,/\/h4>/p" <<< "${text}" \
   | grep -E -v '^--$|<|style=|rel=|^ *$|*/log/*|*/archive/*' \
   | sed -e 's/.*href=.*\/tree\/\(.*\)"/\1/' -e 's/^[[:space:]]*//'
}


#
# Because sr.ht does not have a public API without OAUTH, we need to scrape
# the tags with the commit off the HTML, oh joy
#
domain::plugin::sr::r_tags_and_commits()
{
   log_entry "domain::plugin::sr::r_tags_and_commits" "$@"

   local user="$1"
   local repo="$2"
   local maxpages="$3"
   local perpage=$4

   [ -z "${user}" ] && _internal_fail "user is missing"
   [ -z "${repo}" ] && _internal_fail "repo is missing"

   # the result is paginated, means we only get 10 tags and then have to
   # parse the next url from the response header.
   #
   # We run through the pages, until we get nothing back. Costs us one extra
   # curl call though
   #
   local page
   local n
   local result

   page=1

   perpage="${perpage:-${MULLE_DOMAIN_SR_PER_PAGE}}"
   perpage="${perpage:-100}"

   maxpages="${maxpages:-${MULLE_DOMAIN_SR_MAX_PAGES}}"
   maxpages="${maxpages:-20}"

   local url

   while [ ${page} -le ${maxpages} ]
   do
      # say 1000, it don't matter
      url="https://git.sr.ht/~${user}/${repo}/refs?page=${page}"

      if ! text="`domain::plugin::sr::curl_html "${url}" `"
      then
         log_error "Failed to acquire tags from sr with \"${url}\"."
         RVAL=
         return 1
      fi

      # painfully scrape tags from page

      text="`domain::plugin::sr::scrape <<< "${text}" `"
      if [ -z "${text}" ]
      then
         break
      fi

      r_add_line "${result}" "${text}"
      result="${RVAL}"

      page=$((page + 1))
   done

   log_debug "TAGS: ${result}"

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
# https://git.sr.ht/~mulle_nat/mulle-xcode-to-cmake/archive/0.9.0.tar.gz
# https://git.sr.ht/~mulle_nat/mulle-xcode-to-cmake
#

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
domain::plugin::sr::__parse_url()
{
   log_entry "domain::plugin::sr::__parse_url" "$@"

   local url="$1"

   [ -z "${url}" ] && _internal_fail "URL is empty"

   local s
   local before

#   local _scheme
   local _userinfo
   local _host
   local _port
   local _path
   local _query
   local _fragment

   __url_parse "${url}"
   if [ -z "${_host}" ]
   then
      return 2
   fi

   s="${_path##/}"
   case "${s}" in
      */*)
      ;;

      *)
         return 2
      ;;
   esac

   _user="${s%%/*}"     # get user
   _user="${_user#~}"   # strip a tilde (otherwise just like github)
   s="${s#${_user}/}"   # dial up to repo

   _repo="${s%%/*}"
   s="${s#${_repo}/}"   # checkout rest

   case "${s}" in
      archive/*)
         s="${s#archive/}"   # checkout rest
         s="${s%.gz}"        # remove a .gz if any

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
domain::plugin::sr::r_compose_url()
{
   log_entry "domain::plugin::sr::r_compose_url" "$@"

   local user="$1"
   local repo="$2"
   local tag="$3"
   local scm="$4"
   local scheme="${5:-https}"
   local host="${6:-git.sr.ht}"

   [ -z "${user}" ] && fail "User is required for sr URL"
   [ -z "${repo}" ] && fail "Repo is required for sr URL"

   case "${host}" in
      *\.*)
      ;;

      *)
         host="git.sr.ht"
      ;;
   esac

   repo="${repo%.git}"
   # could use API to get the URL, but laziness...
   case "${scm}" in
      git)
         r_concat "${scheme}://${host}/~${user}/${repo}.git" "${tag}" '##'
      ;;

      tar)
         RVAL="${scheme}://${host}/~${user}/${repo}/archive/${tag:-latest}.tar.gz"
      ;;

      zip)
         RVAL="${scheme}://${host}/~${user}/${repo}/archive/${tag:-latest}.zip"
      ;;

      homepage)
         RVAL="https://${host}/~${user}/${repo}"
      ;;

      none) # TODO: fix
         r_concat "${scheme}://${host}/~${user}/${repo}" "${tag}" "/tag/"
      ;;

      *)
         fail "Unsupported scm ${scm} for sr"
      ;;
   esac
}


#
# lists tag in one line, then commit in the next
# hinges on the fact that sr emits "name" first
# If it doesn't anymore reverse order with sed -n "{h;n;p;g;p}".
# If its now random, move to 'jq'
#
domain::plugin::sr::tags_with_commits()
{
   log_entry "domain::plugin::sr::tags_with_commits" "$@"

   local user="$1"
   local repo="$2"

   if ! r_sr_tags_with_commits "${user}" "${repo}"
   then
      return 1
   fi

   [ ! -z "${RVAL}" ] && echo "${RVAL}"
}

