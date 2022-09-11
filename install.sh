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
  printf "    tui\t\tStart setup wizard ncurses/newt based TUI\n"
  printf "\nRun '%s <command> -h' for more information on a command.\n" \
    "${0##*/}"
}

install_usage() {
  printf "Usage:\t%s install [-eps] <dotfile,...>\n" "${0##*/}"
  printf "\nInstall specified dotfiles by comma separated list. If no dotfiles\nare specified, then install all of them. Alternatively, install all\ndotfiles, but the specified ones.\n"
  printf "\nArguments:\n"
  printf "  -e, --exclude <dotfile,...>\tInstall all dotfiles, exept the comma\n\t\t\t\tseparated listed ones\n\n"
  printf "  -p, --plugins\t\t\tInstall plugins for selected dotfiles. If\n\t\t\t\tno dotfile was especified, then install all\n\t\t\t\tplugins. Available ones are zsh (fast-syntax\n\t\t\t\t-highlighting, fzf-tab, zsh-autosuggestions)\n\t\t\t\tnvim (see init.vim file) and tmux (tpm,\n\t\t\t\ttmux-resurrect, tmux-continuum)\n\n"
  printf "  -s, --symlink\t\t\tInstall the dotfiles as symlinks instead of\n\t\t\t\tcopying them. This is useful to keep using\n\t\t\t\tthis folder to manage your dotfiles with git\n"
  printf "  -y\t\t\t\tAssume yes for overwrite questions\n"
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

  for dir in ${dotfiles}; do
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
  local install_cmd='cp -if'
  local plugins=0
  local yes=0
  local ret=0

  # parse the positional parameters
  while true; do
    case "${1}" in
      -h|--help )
        usage install
        exit 2;;
      -e|--exclude )
        if [ "${dotfiles}" ] || [ "${exclude}" ] || [ -z $2 ]; then
          usage install
          exit 2
        else
          exclude="${2//,/|}"
        fi
        shift 2;;
      -p|--plugins )
        plugins=1
        shift;;
      -s|--symlink )
        # some busybox's 'ln' miss the '-i' option
        install_cmd='cp -ifs'
        shift;;
      -y )
        yes=1
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

  (( yes == 1 )) && install_cmd=${install_cmd//i/}
  [ -z "${dotfiles}" ] && dotfiles=$(ls)

  for dir in ${dotfiles}; do
    # if it's an existent directory and it doesn't start with '.'
    if [ -d "${dir}" ] && [[ "${dir}" != '.'* ]] ; then
      # if it's not meant to be ignored
      if [[ $dir != @($exclude) ]]; then
        # create the subdirs
        find "${dir}"/ -type d -exec bash -c \
          'mkdir -p "${HOME}/${0#*/}"' {} \;
        # install the dotfile
        find "${dir}" -type f -exec bash -c \
          '${0} "${PWD}/${1}" "${HOME}/${1#*/}"' "${install_cmd}" {} \;
      fi
    elif [ ! -e "${dir}" ]; then
      printf "%s\n" "Inexistent dotfile ${dir}"
    fi
  done

  if (( $plugins == 1 )); then
    install_plugins "${dotfiles// /,}"
    ret=$?
  fi

  return $ret
}

install_plugins() {
  local dotfiles=$1
  local ret=0

  for dotfile in ${dotfiles//,/ }; do
    case $dotfile in
      neovim )
        sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        nvim -es -u ~/.config/nvim/init.vim <<< 'PlugUpdate --sync'
        ;;
      tmux )
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/plugins/tmux-resurrect
        git clone https://github.com/tmux-plugins/tmux-continuum ~/.tmux/plugins/tmux-continuum
        ;;
      zsh )
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
          ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
        git clone https://github.com/Aloxaf/fzf-tab \
          ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
        git clone https://github.com/zsh-users/zsh-autosuggestions \
          ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zdharma/fast-syntax-highlighting.git \
          ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
        ;;
      * )
        ;;
    esac
  done

  return $ret
}

tui() {
  # parse the positional parameters
  if (( "${#}" != 0 )); then
    usage tui
    return 2
  fi

#  if command -v dialog >/dev/null 2>&1; then
#    . dial.sh
  if command -v whiptail >/dev/null 2>&1; then
    . whip.sh
  else
    usage tui
    return 1
  fi

  setup_wizard

  return $?
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

