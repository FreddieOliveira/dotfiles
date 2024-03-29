#!/usr/bin/env bash

usage() {
  local usage_type="$1"

  case "$usage_type" in
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
  printf "Usage:\t%s install [-epsy] [<dotfile,...>]\n" "${0##*/}"
  printf "\nInstall specified dotfiles by comma separated list. If no dotfiles\nare specified, then install all of them. Alternatively, install all\ndotfiles, but the specified ones.\n"
  printf "\nArguments:\n"
  printf "  -e, --exclude <dotfile,...>\tInstall all dotfiles, exept the comma\n\t\t\t\tseparated listed ones. It's an error to\n\t\t\t\tspecify a dotfile list and an exclusion list\n\n"
  printf "  -p, --plugins\t\t\tInstall plugins for selected dotfiles. If\n\t\t\t\tno dotfile was especified, then install all\n\t\t\t\tplugins.\n\n"
  printf "  -s, --symlink\t\t\tInstall the dotfiles as symlinks instead of\n\t\t\t\tcopying them. This is useful to keep using\n\t\t\t\tthis folder to manage your dotfiles with git\n\n"
  printf "  -y\t\t\t\tAssume yes for overwrite questions\n"
}

list_usage() {
  printf "Usage:\t%s list [<dotfile,...>]\n" "${0##*/}"
  printf "\nList available dotfiles and its files as well as its plugins.\nIt's possible to specify dotfiles separated by comma. If no\ndotfiles are specified, then list all of them.\n"
}

tui_usage() {
  printf "Usage:\t%s tui\n" "${0##*/}"
  printf "\nStart setup wizard using a ncurse based text user interface.\nIt's necessary to have dialog or whiptail installed.\n"
}

list() {
  local dotfiles
  local ret=1

  # parse the positional parameters
  if (( $# == 0 )); then
    dotfiles=$(ls)
  elif (( $# == 1 )) && [[ "$1" != @('-h'|'--help') ]]; then
    dotfiles="${1//,/ }"
  else
    usage list
    return 2
  fi

  for dir in $dotfiles; do
    # if it's an existent directory and it doesn't start with '.'
    if [[ -d "$dir" ]] && [[ "$dir" != '.'* ]]; then
      printf -- "-%.s" {1..25}
      printf "\n"
      local spaces=$(( (25 - ${#dir}) / 2 ))
      printf " %.s" $(eval echo "{1..$spaces}")
      printf "%s\n" "${dir^^}"
      printf -- "-%.s" {1..25}
      printf "\nDOTFILES:\n"
      # use tree command if it's installed
      if command -v tree 2>/dev/null 1>&2; then
        tree --noreport -a "$dir"
      # otherwise, use find command
      else
        printf "%s\n" "$dir"
        find "$dir" -type f
      fi
      printf "\n"
      ret=0
    elif [[ ! -e "$dir" ]]; then
      printf "%s\n" "Inexistent dotfile $dir"
    fi

    case "$dir" in
      nvim )
        printf "PLUGINS:\n"
        printf "plug-vim\nsee init.vim file\n\n"
        ;;
      tmux )
        printf "PLUGINS:\n"
        printf "tpm\ntmux-resurrect\ntmux-continuum\n\n"
        ;;
      zsh )
        printf "PLUGINS:\n"
        printf "oh-my-zsh\nfast-syntax-highlighting\nfzf-tab\nzsh-autosuggestions\n\n"
        ;;
    esac
  done

  return $ret
}

install() {
  local dotfiles dotfiles_aux exclude
  local plugins=0
  local yes=0
  local symlink=0
  local ret=0

  # parse the positional parameters
  while true; do
    case "$1" in
      -h | --help )
        usage install
        exit 2;;
      -e | --exclude )
        if [[ "$dotfiles_aux" ]] || [[ "$exclude" ]] || [[ -z "$2" ]]; then
          usage install
          exit 2
        else
          exclude="${2//,/|}"
        fi
        shift 2;;
      -p | --plugins )
        plugins=1
        shift;;
      -s | --symlink )
        # some busybox's 'ln' miss the '-i' option
        symlink=1
        shift;;
      -y )
        yes=1
        shift;;
      '' )
        break;;
      * )
        if [[ "$dotfiles_aux" ]] || [[ "$exclude" ]]; then
          usage install
          exit 2
        else
          dotfiles_aux="${1//,/ }"
        fi
        shift;;
    esac
  done

  [[ -z "$dotfiles_aux" ]] && dotfiles_aux="$(ls)"

  for dir in $dotfiles_aux; do
    # if it's an existent directory and it doesn't start with '.'
    if [[ -d "$dir" ]] && [[ "$dir" != '.'* ]]; then
      # if it's not meant to be ignored
      if [[ "$dir" != @($exclude) ]]; then
        dotfiles="$dotfiles $dir"
      fi
    elif [[ ! -e "$dir" ]]; then
      printf "%s\n" "Inexistent dotfile $dir"
    fi
  done

  install_dotfiles "$dotfiles" "$symlink" "$yes"

  if (( plugins == 1 )); then
    install_plugins "$dotfiles" "$yes"
    ret=$?
  fi

  return $ret
}

install_dotfiles() {
  local dotfiles="$1"
  local symlink="$2"
  local yes="$3"
  local install_cmd='cp -f'
  local ret=0

  (( symlink == 1 )) && install_cmd="${install_cmd}s"
  (( yes == 0 )) && install_cmd="${install_cmd}i"

  for dotfile in $dotfiles; do
    # create the subdirs
    find "$dotfile/" -type d -exec bash -c \
      'mkdir -p "$HOME/${0#*/}"' {} \;
    # install the dotfile
    find "$dotfile" -type f -exec bash -c \
      '$0 "$PWD/$1" "$HOME/${1#*/}"' "$install_cmd" {} \;
  done

  return $ret
}

install_plugins() {
  local dotfiles="$1"
  local ret=0

  for dotfile in $dotfiles; do
    case "$dotfile" in
      neovim )
        install_nvim_plugins
        ;;
      tmux )
        install_tmux_plugins
        ;;
      zsh )
        install_zsh_plugins
        ;;
      * )
        ;;
    esac
  done

  return $ret
}

install_nvim_plugins() {
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  nvim -es -u ~/.config/nvim/init.vim <<< 'PlugUpdate --sync'
}

install_tmux_plugins() {
  git clone --depth=1 https://github.com/tmux-plugins/tpm \
    ~/.tmux/plugins/tpm
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
}

install_zsh_plugins() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  git clone --depth=1 https://github.com/Aloxaf/fzf-tab \
    "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab"
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
      "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting"
}

tui() {
  # parse the positional parameters
  if (( $# != 0 )); then
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
  local command="$1"

  case "$command" in
    install ) install "${@:2}" ; ret=$?;;
    list ) list "${@:2}" ; ret=$?;;
    tui ) tui "${@:2}" ; ret=$?;;
    * ) usage ; ret=2;;
  esac

  exit $ret
}

cd "${BASH_SOURCE[0]%/*}" || exit 1
main "$@"

