# bash completion for mulle-domain                            -*- shell-script -*-

# This bash completions script was generated automatically
# by the getopts-bash-completion generator.

_mulle_domain_complete()
{
   local cur prev words cword split=false
   _init_completion -s || return

   case $prev in
      --domain|--fallback-domain)
         local domains=$("${words[0]}" plugin list 2>/dev/null)
         COMPREPLY=( $(compgen -W "$domains" -- "$cur") )
         return
         ;;
      --github-user)
         COMPREPLY=()
         return
         ;;
      --scm)
         COMPREPLY=( $(compgen -W "git tar zip homepage none" -- "$cur") )
         return
         ;;
      --scheme)
         COMPREPLY=( $(compgen -W "https http" -- "$cur") )
         return
         ;;
      --git-terminal-prompt|--user|--repo|--tag|--host|--branch|--prefix|--*-token|--*-per-page|--*-max-pages|--*github|--*github-user|--*git-terminal-prompt|--*version)
         COMPREPLY=()  # no completion
         return
         ;;
   esac

   $split && return

   local cmds="compose-url nameguess parse-url resolve tags tags-with-commits list plugin compose commit-for-tag libexec-dir homepage-url guess typeguess type-guess guess-name name-guess era libexec-path uname version"

   local cmd i
   for ((i = 1; i < ${#words[@]}-1; i++)); do
      if [[ ${words[i]} != -* ]]; then
         cmd=${words[i]}
         break
      fi
   done

   case $cmd in
      homepage-url|parse-url|guess|nameguess|typeguess|type-guess|guess-name|name-guess)
         local parse_options=(
            "--guess" "--no-guess" "--domain" "--fallback-domain"
            "--no-fallback" "--prefix"
         )
         if [[ $cur == -* ]]; then
            COMPREPLY=( $(compgen -W "${parse_options[*]}" -- "$cur") )
         else
            COMPREPLY=( $(compgen -W "https://" -- "$cur") )
         fi
         ;;
      resolve)
         local resolve_options=(
            "--domain" "--latest" "--resolve-single-tag"
            "--no-resolve-single-tag" "--scm"
         )
         if [[ $cur == -* ]]; then
            COMPREPLY=( $(compgen -W "${resolve_options[*]}" -- "$cur") )
         else
            COMPREPLY=( $(compgen -W "https://" -- "$cur") )
         fi
         ;;
      tags|tag-exists|tags-with-commits|commit-for-tag|tags-for-commit|tag-aliases)
         local tags_options=(
            "--user" "--repo" "--token" "--per-page" "--max-pages" "--domain-token"
            "--all"
         )
         case $prev in
            --user|--repo|--token|--domain-token)
               COMPREPLY=()
               return
               ;;
            --per-page|--max-pages)
               COMPREPLY=()
               return
               ;;
         esac
         if [[ $cur == -* ]]; then
            COMPREPLY=( $(compgen -W "${tags_options[*]}" -- "$cur") )
         else
            COMPREPLY=( $(compgen -W "https://" -- "$cur") )
         fi
         ;;
      compose|compose-url|url-compose)
         local compose_options=(
            "--branch" "--domain" "--host" "--repo" "--scheme" "--scm" "--tag" "--user"
         )
         if [[ $cur == -* ]]; then
            COMPREPLY=( $(compgen -W "${compose_options[*]}" -- "$cur") )
         else
            COMPREPLY=( $(compgen -W "https://" -- "$cur") )
         fi
         ;;
      plugin)
         local plugin_commands=("list")
         if [[ $cword -eq $i ]]; then
            COMPREPLY=( $(compgen -W "${plugin_commands[*]}" -- "$cur") )
         fi
         ;;
      *)
         if [[ $cur == -* ]]; then
            # Handle dynamic domain-specific options
            local domains=$("${words[0]}" plugin list 2>/dev/null)
            COMPREPLY=( $(compgen -f -- "$cur") )
            local domain_options
            for domain in $domains; do
               domain_options+="$domain-token $domain-max-pages $domain-per-page "
            done
            COMPREPLY+=( $(compgen -W "$domain_options --help" -- "$cur") )
         else
            COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
         fi
         ;;
   esac
} && complete -F _mulle_domain_complete mulle-domain
