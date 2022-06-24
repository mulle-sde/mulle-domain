#! /usr/bin/env bash
#
#   Copyright (c) 2021 Nat! - Mulle kybernetiK
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
MULLE_DOMAIN_PLUGIN_SOURCEFORGE_SH="included"



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
# https://netcologne.dl.sourceforge.net/project/freeglut/freeglut/3.2.1/freeglut-3.2.1.tar.gz
# MEMO: quickly hacked!. Only works for tar.gz at the moment.
#
domain::plugin::sourceforge::__parse_url()
{
   log_entry "domain::plugin::sourceforge::__parse_url" "$@"

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

   local project 

   project="${s%%/*}"    # get "project"
   s="${s#${project}/}"  # dial up to user

   _user="${s%%/*}"     # get user
   s="${s#${_user}/}"   # dial up to repo

   _repo="${s%%/*}"
   s="${s#${_repo}/}"   # dial up to repo

   _tag="${s%%/*}"
   s="${s#${_tag}/}"     # checkout rest

   case "${s}" in
      *\.gz)
         s="${s##*/}"        # checkout filename
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
         return 2
      ;;
   esac
}



#
# compose an URL from user repository name (repo), username (user)
# possibly a version (tag) and the desired SCM (git or tar usually)
#
domain::plugin::sourceforge::r_compose_url()
{
   log_entry "domain::plugin::sourceforge::r_compose_url" "$@"

   local user="${1:-whoever}"
   local repo="$2"
   local tag="$3"
   local scm="$4"
   local scheme="${5:-https}"
   local host="${6:-sourceforge.com}"

   [ -z "${user}" ] && fail "User is required for sourceforge URL"
   [ -z "${repo}" ] && fail "Repo is required for sourceforge URL"

   repo="${repo%.git}"
   # could use API to get the URL, but laziness...
   case "${scm}" in
      tar)
         RVAL="${scheme}://${host}/project/${user}/${repo}/${tag}/${repo}-${tag}.tar.gz"
      ;;
      *)
         fail "Unsupported scm ${scm} for sourceforge"
      ;;
   esac
}


#
# lists tag in one line, then commit in the next
# hinges on the fact that sourceforge emits "name" first
# If it doesn't anymore reverse order with sed -n "{h;n;p;g;p}".
# If its now random, move to 'jq'
#
domain::plugin::sourceforge::tags_with_commits()
{
   log_entry "domain::plugin::sourceforge::tags_with_commits" "$@"

   local user="$1"
   local repo="$2"

   return 1
}

:
