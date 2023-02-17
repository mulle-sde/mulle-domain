# shellcheck shell=bash
#
#   Copyright (c) 2015-2018 Nat! - Mulle kybernetiK
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
MULLE_DOMAIN_PLUGIN_SH='included'


domain::plugin::usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} plugin [options] <command>

   Currently the only command is "list", which lists the available domains.
   Known domains can be extended with plugins in:

   ${MULLE_DOMAIN_LIBEXEC_DIR}/plugins

Options:
   -h : this help

EOF

   exit 1
}


domain::plugin::load_if_present()
{
   log_entry "domain::plugin::load_if_present" "$@"

   local name="$1"

   [ -z "${name}" ] && return 127 # don't warn though, it's boring

   local variable

   include "case"

   r_smart_upcase_identifier "${name}" # not file
   variable="MULLE_DOMAIN_PLUGIN_${RVAL}_SH"

   local value

   r_shell_indirect_expand "${variable}"
   value="${RVAL}"

   if [ ! -z "${value}" ]
   then
      return 0
   fi

   if [ ! -f "${MULLE_DOMAIN_LIBEXEC_DIR}/plugins/${name}.sh" ]
   then
      log_verbose "Domain \"${name}\" is not supported (no plugin found)"
      return 127
   fi

   # shellcheck source=plugins/scm/symlink.sh
   . "${MULLE_DOMAIN_LIBEXEC_DIR}/plugins/${name}.sh"

   # doppelt gemoppelt, macht eigentlich schon das plugin
   eval "${variable}='included'"

   return 0
}


domain::plugin::load()
{
   log_entry "domain::plugin::load" "$@"

   local name="$1"

   [ -z "${name}" ] && fail "Empty domain name"

   if ! domain::plugin::load_if_present "${name}"
   then
      fail "Domain \"${name}\" is not supported (no plugin found)"
   fi
}


domain::plugin::list()
{
   log_entry "domain::plugin::list"

   local upcase
   local plugindefine
   local pluginpath
   local name

   [ -z "${DEFAULT_IFS}" ] && _internal_fail "DEFAULT_IFS not set"
   [ -z "${MULLE_DOMAIN_LIBEXEC_DIR}" ] && _internal_fail "MULLE_DOMAIN_LIBEXEC_DIR not set"


   .foreachline pluginpath in `dir_list_files "${MULLE_DOMAIN_LIBEXEC_DIR}/plugins" "*.sh"`
   .do
      basename -- "${pluginpath}" .sh
   .done

   IFS="${DEFAULT_IFS}"
}



domain::plugin::load_all()
{
   log_entry "domain::plugin::load_all"


   [ -z "${DEFAULT_IFS}" ] && _internal_fail "DEFAULT_IFS not set"
   [ -z "${MULLE_DOMAIN_LIBEXEC_DIR}" ] && _internal_fail "MULLE_DOMAIN_LIBEXEC_DIR not set"

   log_fluff "Loading plugins..."

   local variable
   local pluginpath
   local value

   .foreachline pluginpath in `dir_list_files "${MULLE_DOMAIN_LIBEXEC_DIR}/plugins" "*.sh"`
   .do
      r_extensionless_basename "${pluginpath}"
      r_smart_upcase_identifier "${RVAL}"  # not file
      variable="MULLE_DOMAIN_PLUGIN_${RVAL}_SH"

      r_shell_indirect_expand "${variable}"
      value="${RVAL}"

      if [ ! -z "${value}" ]
      then
         .continue
      fi

      # shellcheck source=plugins/github.sh
      . "${pluginpath}" || exit 1

      eval "${variable}='included'"
   .done
}


#
# bunch of functionality that interfaces the plugin API with the
# rest of the code
#
domain::plugin::load_if_needed()
{
   log_entry "domain::plugin::load_if_needed" "$@"

   local domain="$1"

   local domain_identifier

   r_identifier "${domain}"
   domain_identifier="${RVAL}"

   #
   # if unsupported just emit the URL as is
   #
   if ! domain::plugin::load_if_present "${domain_identifier}" "domain"
   then
      log_fluff "Domain \"${domain_identifier}\" is not supported"
      return 127
   fi
}


domain::plugin::call_function()
{
   log_entry "domain::plugin::call_function" "$@"

   local domain="$1"
   local functionname="$2"

   shift 2

   domain::plugin::load_if_needed "${domain}" || return 127

   callback="domain::plugin::${domain}::${functionname}"

   if ! shell_is_function "${callback}"
   then
      _internal_fail "Domain plugin \"${domain}\" has no \"${callback}\" function"
      return 126
   fi

   ${callback} "$@"
}


#
# PLUGIN API interface
#
domain::plugin::tags_with_commits()
{
   log_entry "domain::plugin::tags_with_commits" "$@"

   local domain="$1"; shift

   # local user="$1"
   # local repo="$2"

   domain::plugin::call_function "${domain}" tags_with_commits "$@"
}


domain::plugin::r_compose_url()
{
   log_entry "domain::plugin::r_compose_url" "$@"

   local domain="$1"; shift

   # local user="$1"
   # local repo="$2"
   # local tag="$3"
   # local scm="$4"

   domain::plugin::call_function "${domain}" r_compose_url "$@"
}


# _scheme
# _user
# _repo
# _tag
# _scm
#
domain::plugin::parse_url()
{
   log_entry "domain::plugin::parse_url" "$@"

   local domain="$1"; shift

   # local url="$1"

   domain::plugin::call_function "${domain}" __parse_url "$@"
}


domain::plugin::main()
{
   log_entry "domain::plugin::main" "$@"

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            domain::plugin::usage
         ;;

         -*)
            domain::plugin::usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -lt 1 ] && domain::plugin::usage "missing argument"
   [ $# -gt 1 ] && shift && domain::plugin::usage "superflous arguments $*"

   local cmd="$1"
   shift

   case "${cmd}" in
      list)
         [ $# -ne 0 ] && domain::plugin::usage "superflous parameters"

         log_info "Plugins"
         domain::plugin::list
      ;;

      "")
         domain::plugin::usage
      ;;

      *)
         domain::plugin::usage "Unknown command \"$1\""
      ;;
   esac
}
