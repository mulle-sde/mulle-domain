#! /usr/bin/env bash
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
MULLE_DOMAIN_PLUGIN_SH="included"


domain_plugin_usage()
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



domain_plugin_load_if_present()
{
   log_entry "domain_plugin_load_if_present" "$@"

   local name="$1"

   local variable

   r_uppercase "${name}"
   variable="_MULLE_DOMAIN_PLUGIN_LOADED_${RVAL}"

   if [ "${!variable}" = 'YES' ]
   then
      return 0
   fi

   if [ ! -f "${MULLE_DOMAIN_LIBEXEC_DIR}/plugins/${name}.sh" ]
   then
      log_verbose "\"${name}\" is not supported (no plugin found)"
      return 127
   fi

   # shellcheck source=plugins/scm/symlink.sh
   . "${MULLE_DOMAIN_LIBEXEC_DIR}/plugins/${name}.sh"

   eval "${variable}='YES'"

   return 0
}



domain_plugin_load()
{
   log_entry "domain_plugin_load" "$@"

   local name="$1"

   if ! domain_plugin_load_if_present "${name}"
   then
      fail "\"${name}\" is not supported (no plugin found)"
   fi
}


domain_plugin_list()
{
   log_entry "domain_plugin_list"

   local upcase
   local plugindefine
   local pluginpath
   local name

   [ -z "${DEFAULT_IFS}" ] && internal_fail "DEFAULT_IFS not set"
   [ -z "${MULLE_DOMAIN_LIBEXEC_DIR}" ] && internal_fail "MULLE_DOMAIN_LIBEXEC_DIR not set"


   IFS=$'\n'
   for pluginpath in `ls -1 "${MULLE_DOMAIN_LIBEXEC_DIR}/plugins/"*.sh`
   do
      basename -- "${pluginpath}" .sh
   done

   IFS="${DEFAULT_IFS}"
}



domain_plugin_load_all()
{
   log_entry "domain_plugin_load_all"

   local upcase
   local plugindefine
   local pluginpath
   local name

   [ -z "${DEFAULT_IFS}" ] && internal_fail "DEFAULT_IFS not set"
   [ -z "${MULLE_DOMAIN_LIBEXEC_DIR}" ] && internal_fail "MULLE_DOMAIN_LIBEXEC_DIR not set"

   log_fluff "Loading plugins..."

   IFS=$'\n'
   for pluginpath in `ls -1 "${MULLE_DOMAIN_LIBEXEC_DIR}/plugins"/*.sh`
   do
      IFS="${DEFAULT_IFS}"

      name="`basename -- "${pluginpath}" .sh`"

      r_identifier "${name}"
      r_uppercase "${RVAL}"
      plugindefine="MULLE_DOMAIN_PLUGIN_${RVAL}_SH"

      if [ -z "${!plugindefine}" ]
      then
         # shellcheck source=plugins/symlink.sh
         . "${pluginpath}"

         log_fluff "plugin \"${name}\" loaded"
      fi
   done

   IFS="${DEFAULT_IFS}"
}


#
# bunch of functionality that interfaces the plugin API with the
# rest of the code
#
domain_load_plugin_if_needed()
{
   log_entry "domain_load_plugin_if_needed" "$@"

   local domain="$1"

   local domain_identifier

   r_identifier "${domain}"
   domain_identifier="${RVAL}"

   if [ -z "${MULLE_DOMAIN_PLUGIN_SH}" ]
   then
      . "${MULLE_DOMAIN_LIBEXEC_DIR}/mulle-domain-plugin.sh"
   fi

   #
   # if unsupported just emit the URL as is
   #
   if ! domain_plugin_load_if_present "${domain_identifier}" "domain"
   then
      log_warning "Warning: domain \"${domain_identifier}\" is not supported"
      return 127
   fi
}


domain_call_plugin_function()
{
   log_entry "domain_call_plugin_function" "$@"

   local domain="$1"; shift
   local callback="$1"

   domain_load_plugin_if_needed "${domain}" || return 127

   if [ "`type -t "${callback}"`" != "function" ]
   then
      internal_fail "Domain plugin \"${domain}\" has no \"${callback}\" function"
      return 126
   fi

   "$@"
}


#
# PLUGIN API interface
#
domain_tags_with_commits()
{
   log_entry "domain_tags_with_commits" "$@"

   local domain="$1"; shift

   # local user="$1"
   # local repo="$2"

   domain_call_plugin_function "${domain}" domain_${domain}_tags_with_commits "$@"
}


r_domain_compose_url()
{
   log_entry "r_domain_compose_url" "$@"

   local domain="$1"; shift

   # local user="$1"
   # local repo="$2"
   # local tag="$3"
   # local scm="$4"

   domain_call_plugin_function  "${domain}" r_domain_${domain}_compose_url "$@"
}


# _scheme
# _user
# _repo
# _tag
# _scm
#
domain_parse_url()
{
   log_entry "domain_parse_url" "$@"

   local domain="$1"; shift

   # local url="$1"

   domain_call_plugin_function  "${domain}" domain_${domain}_parse_url "$@"
}


domain_plugin_main()
{
   log_entry "domain_plugin_main" "$@"

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            domain_plugin_usage
         ;;

         -*)
            domain_plugin_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -lt 1 ] && domain_plugin_usage "missing argument"
   [ $# -gt 1 ] && shift && domain_plugin_usage "superflous arguments $*"

   local cmd="$1"
   shift

   case "${cmd}" in
      list)
         [ $# -ne 0 ] && domain_plugin_usage "superflous parameters"

         log_info "Plugins"
         domain_plugin_list
      ;;

      "")
         domain_plugin_usage
      ;;

      *)
         domain_plugin_usage "Unknown command \"$1\""
      ;;
   esac
}
