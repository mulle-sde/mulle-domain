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
MULLE_DOMAIN_PLUGIN_GENERIC_SH='included'



####
#### PLUGIN API
####

domain::plugin::generic::string_could_be_a_version()
{
   case "${1}" in
      [vV]*[0-9_.-]*|[0-9]*[0-9_.-]*)
         return 0
      ;;
   esac
   return 1
}


#
# _scheme
# _user
# _repo
# _tag
# _scm
#
# just like github, but a bit more lenient
#
# https://generic.com/mulle-sde/mulle-domain/archive/0.45.0.tar.gz
# https://generic.com/mulle-sde/mulle-domain/archive/
# https://generic.com/foo.git
# https://generic.com/downloads/foo-1.2.3.git
#
domain::plugin::generic::__parse_archive_url()
{
   local s="$1"

   local filename

   filename="${s##*/}"   # checkout rest

   local subdir
   local rest
   local found

   for subdir in archive archives release releases download downloads
   do
      case "${s}" in
         *${subdir}/*)
            rest="${s#*${subdir}/}"
            rest="${rest%${filename}}"
            rest="${rest%/}"
            s="${s%${subdir}/*}"
            found='YES'
         ;;

         *)
            continue
         ;;
      esac
      break
   done

   if [ "${found}" != 'YES' ]
   then
      s="${s%/${filename}}"
      rest="${s}"
   fi

   _user=
   case "${s}" in
      */*)
         _user="${s%%/*}"     # get user
         s="${s#${_user}/}"   # dial up to repo
      ;;
   esac

   _repo="${s%%/*}"
   s="${s#${_repo}/}"          # checkout rest

   _tag=

   local version

   # pick up version as the last component before filename ?
   version="${rest##*/}"
   if domain::plugin::generic::string_could_be_a_version "${version}"
   then
      _tag="${version}"
      return
   fi

   # pick up version as the component after user/repo ?
   case "${s}" in
      */*)
         version="${s%%/*}"     # get next
         if domain::plugin::generic::string_could_be_a_version "${version}"
         then
            _tag="${version}"
         fi
         return
      ;;
   esac

   local repo

   repo=${_repo}

   if [ -z "${_repo}" -o "${_repo}" = "${filename}" ]
   then
      #
      # try to figure out https://xxx.com/bar-1.2.3.tar
      # as repo:bar and tag 1.2.3 (for sports ?)
      #
      _repo="${filename%%.[A-Za-z]*}" # remove all extensions
      case "${_repo}" in
         *[_-][0-9]*)

            repo="${_repo%[_-][0-9]*}"
            version="${_repo#${repo}[_-]}"
         ;;
      esac
   else
      # so lets see, if we can finagle a version from the
      # filename
      if [ ! -z "${_repo}" ]
      then
         version="${filename%%.[A-Za-z]*}" # remove all non numeric extensions
         version="${version#${_repo}}"
         version="${version##[-_.]}"    # remove some common delimeters fore
         version="${version%%[-_.]}"    # and after
      fi
   fi

   # if it looks reasonably like a version, take it
   if domain::plugin::generic::string_could_be_a_version "${version}"
   then
      _tag="${version}"
      _repo="${repo}"
   fi
}


domain::plugin::generic::__parse_file_url()
{
   log_entry "domain::plugin::generic::__parse_file_url" "$@"

   _repo="$1"
}



domain::plugin::generic::__parse_repository_url()
{
   log_entry "domain::plugin::generic::__parse_repository_url" "$@"
   
   local s="$1"

   _user=
   case "${s}" in
      */*)
         _user="${s%%/*}"     # get user
         s="${s#${_user}/}"   # dial up to repo
      ;;
   esac

   _repo="${s%%/*}"
   s="${s#${_repo}/}"   # checkout rest

   _repo="${_repo%.${_scm}}"
}


domain::plugin::generic::__parse_url()
{
   log_entry "domain::plugin::generic::__parse_url" "$@"

   local url="$1"

   [ -z "${url}" ] && _internal_fail "URL is empty"

   local s

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
      *.zip)
         _scm="zip"
         domain::plugin::generic::__parse_archive_url "${s}"
         return $?
      ;;

      *.tar|*.tgz)
         _scm="tar"
         domain::plugin::generic::__parse_archive_url "${s}"
         return $?
      ;;

      *.tar.*)
         if url_has_file_compression_extension "${s}"
         then
            _scm="tar"
            domain::plugin::generic::__parse_archive_url "${s}"
            return $?
         fi
      ;;

      # html/css ? hmm... that's probably a bug
      *.dat|*.txt|*.md|*.css|*.html|*.c|*.m|*.aam|*.cpp|*.png|*.jpg|*.tiff|*.obj|*.aiff|*.aam)
         _scm="file"
         domain::plugin::generic::__parse_file_url "${s}"
         return $?
      ;;
   esac


   # probably git or so
   case "${pruned}" in
      *.svn)
         _scm='svn'
         return 1
      ;;

      *)
         _scm='git'
         _tag=
      ;;
   esac

   domain::plugin::generic::__parse_repository_url "${s}"
}



#
# compose an URL from user repository name (repo), username (user)
# possibly a version (tag) and the desired SCM (git or tar usually)
#
domain::plugin::generic::r_compose_url()
{
   log_entry "domain::plugin::generic::r_compose_url" "$@"

   local user="$1"
   local repo="$2"
   local tag="$3"
   local scm="$4"
   local scheme="${5:-https}"
   local host="$6"

 #  [ -z "${user}" ] && fail "User is required for generic URL"
   [ -z "${repo}" ] && fail "Repo is required for generic URL"
   [ -z "${host}" ] && fail "Host is required for generic URL"

   case "${host}" in
      *\.*)
      ;;

      *)
         host="${host}.com"
      ;;
   esac

   local opt_user

   if [ ! -z "${user}" ]
   then
      opt_user="${user}/"
   fi

   repo="${repo%.git}"
   # could use API to get the URL, but laziness...
   case "${scm}" in
      git)
         r_concat "${scheme}://${host}/${opt_user}${repo}.git" "${tag}" '##'
      ;;

      tar)
         RVAL="${scheme}://${host}/${opt_user}${repo}/archive/${tag:-latest}.tar.gz"
      ;;

      zip)
         RVAL="${scheme}://${host}/${opt_user}${repo}/archive/${tag:-latest}.zip"
      ;;

      none)
         r_concat "https://${host}/${opt_user}/${repo}" "${tag}" "/tree/"
      ;;

      *)
         fail "Unsupported scm ${scm} for generic"
      ;;
   esac
}


#
# lists tag in one line, then commit in the next
# hinges on the fact that generic emits "name" first
# If it doesn't anymore reverse order with sed -n "{h;n;p;g;p}".
# If its now random, move to 'jq'
#
domain::plugin::generic::tags_with_commits()
{
   log_entry "generic_tags_with_commits" "$@"

   local user="$1"
   local repo="$2"

   return 1
}

:
