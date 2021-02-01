#!/usr/bin/env bash

usage() {
  local usage_type="${@}"

  case "${usage_type}" in
    install ) install_usage;;
    list ) list_usage;;
    tui ) tui_usage;;
    * ) general_usage;;
  esac
}

general_usage() {
  printf "Usage:\t%s <command> [<args>]\n" "${0##*/}"
  printf "\nInstall or list available dotfiles\n"
  printf "\nCommands:\n"
  printf "    install\tInstall specified dotfiles\n"
  printf "    list\tList available dotfiles and its files\n"
  printf "    tui\t\tStart setup wizard ncurse based TUI\n"
  printf "\nRun '%s <command> -h' for more information on a command.\n" \
    "${0##*/}"
}

install_usage() {
  printf "Usage:\t%s install [-es] <dotfile,...>\n" "${0##*/}"
  printf "\nInstall specified dotfiles by comma separated list. If no dotfiles\nare specified, then install all of them. Alternatively, install all\ndotfiles, but the specified ones.\n"
  printf "\nArguments:\n"
  printf "  -e, --exclude <dotfile,...>\tInstall all dotfiles, exept the comma\n\t\t\t\tseparated listed ones\n"
  printf "  -s, --symlink\t\t\tInstall the dotfiles as symlinks instead of\n\t\t\t\tcopying them. This is useful to keep using\n\t\t\t\tthis folder to manage your dotfiles with git\n"
}

list_usage() {
  printf "Usage:\t%s list [<dotfile,...>]\n" "${0##*/}"
  printf "\nList available dotfiles and its files. It's possible to specify dotfiles\nseparated by comma. If no dotfiles are specified, then list all of them.\n"
}

tui_usage() {
  printf "Usage:\t%s tui\n" "${0##*/}"
  printf "\nStart setup wizard using a ncurse based text user interface.\nIt's necessary to have dialog or whiptail installed.\n"
}

list() {
  local dotfiles
  local ret=1

  # parse the positional parameters
  if [ "${#}" -eq 0 ]; then
    dotfiles=$(ls)
  elif [ "${#}" -eq 1 ] && [[ "${1}" != @('-h'|'--help') ]]; then
    dotfiles="${1//,/ }"
  else
    usage list
    return 2
  fi

  # convert the space separated string 'dotfiles'
  # into an array for the for loop command
  for dir in $(printf "%s" "${dotfiles}"); do
    # if it's an existent directory and it doesn't start with '.'
    if [ -d "${dir}" ] && [[ "${dir}" != '.'* ]] ; then
      # use tree command if it's installed
      if command -v tree 2>/dev/null 1>&2; then
        tree --noreport -a "${dir}"
      # otherwise, use find command
      else
        printf "%s\n" "${dir}"
        find "${dir}" -type f
      fi
      printf "\n"
      ret=0
    elif [ ! -e "${dir}" ]; then
      printf "%s\n" "Inexistent dotfile ${dir}"
    fi
  done

  return "${ret}"
}

install() {
  local dotfiles exclude
  local install_cmd='cp -i'
  local ret=1

  # parse the positional parameters
  while true; do
    case "${1}" in
      -h|--help )
        usage install
        exit 2;;
      -e|--exclude )
        if [ "${dotfiles}" ] || [ "${exclude}" ]; then
          usage install
          exit 2
        else
          exclude="${2//,/|}"
        fi
        shift 2;;
      -s|--symlink )
        # some busybox's 'ln' miss the '-i' option
        install_cmd='cp -is'
        shift;;
      '' )
        break;;
      * )
        if [ "${dotfiles}" ] || [ "${exclude}" ]; then
          usage install
          exit 2
        else
          dotfiles="${1//,/ }"
        fi
        shift;;
    esac
  done

  [ -z "${dotfiles}" ] && dotfiles=$(ls)

  # convert the space separated string 'dotfiles'
  # into an array for the for loop command
  for dir in $(printf "%s" "${dotfiles}"); do
    # if it's an existent directory and it doesn't start with '.'
    if [ -d "${dir}" ] && [[ "${dir}" != '.'* ]] ; then
      # create the subdirs
      find "${dir}"/ -type d -exec bash -c \
        '[[ "${1}" != @(${2}) ]] && mkdir -p "${HOME}/${3#*/}"' \
        -- "${dir}" "${exclude}" {} \;
      # install the dotfiles
      find "${dir}" -type f -exec bash -c \
        '[[ "${1}" != @(${2}) ]] && ${3} "${PWD}/${4}" "${HOME}/${4#*/}"' \
        -- "${dir}" "${exclude}" "${install_cmd}" {} \;
      # if we installed at least one dotfile, return success
      ret=0
    elif [ ! -e "${dir}" ]; then
      printf "%s\n" "Inexistent dotfile ${dir}"
    fi
  done

  return "${ret}"
}

tui() {
  local ret

  # parse the positional parameters
  if (( "${#}" != 0 )); then
    usage tui
    return 2
  fi

  if command -v dialog >/dev/null 2>&1; then
    . dial.sh
    ret=$(setup_wizard)
  elif command -v whiptail >/dev/null 2>&1; then
    . whip.sh
    ret=$(setup_wizard)
  else
    usage tui
    ret=1
  fi

  return $ret
}

main() {
  local ret=1
  local command="${1}"

  case "${command}" in
    install ) install "${@:2}" ; ret="${?}";;
    list ) list "${@:2}" ; ret="${?}";;
    tui ) tui "${@:2}" ; ret="${?}";;
    * ) usage ; ret=2;;
  esac

  exit "${ret}"
}

cd "${BASH_SOURCE[0]%/*}"
main "${@}"
