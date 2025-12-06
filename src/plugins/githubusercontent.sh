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
MULLE_DOMAIN_PLUGIN_GITHUBUSERCONTENT_SH='included'



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
# https://githubusercontent.com/mulle-sde/mulle-domain/archive/0.45.0.tar.gz
# https://githubusercontent.com/mulle-sde/mulle-domain/archive/
#
domain::plugin::githubusercontent::__parse_url()
{
   log_entry "domain::plugin::githubusercontent::__parse_url" "$@"

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

   # https://raw.githubusercontent.com/mulle-c/xxHash/refs/heads/dev/xxhash.h
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
   s="${s#${_repo}}"    # checkout rest

   _path="${s}"
   _tag=
   _scm="none"
}



#
# compose an URL from user repository name (repo), username (user)
# possibly a version (tag) and the desired SCM (git or tar usually)
#
domain::plugin::githubusercontent::r_compose_url()
{
   log_entry "domain::plugin::githubusercontent::r_compose_url" "$@"

   local user="${1:-whoever}"
   local repo="$2"
   local tag="$3"
   local scm="$4"
   local scheme="${5:-https}"
   local host="${6:-githubusercontent.com}"

   [ -z "${repo}" -a "${scm}" != "homepage" ] && fail "Repo is required for generic URL ($*)"
   [ -z "${user}" ] && fail "User is required for githubusercontent URL ($*)"

   # https://raw.githubusercontent.com/mulle-c/xxHash/refs/heads/dev/xxhash.h

   # could use API to get the URL, but laziness...
   case "${scm}" in
      none)
         r_concat "https://${host}/${user}/${repo}"
      ;;

      homepage)
         r_concat "https://${host}/${user}" "${repo}" "/"
      ;;

      *)
         fail "Unsupported scm \"${scm}\" for githubusercontent"
      ;;
   esac
}


#
# lists tag in one line, then commit in the next
# hinges on the fact that githubusercontent emits "name" first
# If it doesn't anymore reverse order with sed -n "{h;n;p;g;p}".
# If its now random, move to 'jq'
#
domain::plugin::githubusercontent::tags_with_commits()
{
   log_entry "github_tags_with_commits" "$@"

   local user="$1"
   local repo="$2"

   return 1
}

