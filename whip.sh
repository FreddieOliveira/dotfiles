#!/usr/bin/env bash

PACKAGES=('gcc' 'GNU compiler' OFF \
          'gdb' 'GNU debugger' OFF \
          'gimp' 'GNU Image Manipulation Program' OFF \
          'neomutt' 'Patched Mutt mail client' OFF \
          'neovim' 'Imoroved VIM' OFF \
          'tmux' 'Terminal multiplexer' OFF)
          'wine' 'Microsoft Windows environment' OFF \
          'zsh' 'Z shell for Z warriors' OFF \

DOTFILES=('neomutt' 'Basic initial setup' OFF \
          'neovim' 'Config and plugins' OFF \
          'tmux' 'Cool dotfile' OFF \
          'zsh' 'Oh My Zsh and plugins' OFF)

function main_menu() {
  whiptail --title " Main menu " --menu \
    "Choose an option" 25 78 16 \
    #"<-- Back" "Return to the main menu." \
    "1. Install packages" "Only install packages." \
    "2. Modify User" "Only install the dotfiles." \
    "3. Setup packages" "Install the dotfiles and additional packages."
}

function install_packages() {
  local packages

  # swap stdout and stderr from whiptail process and save its
  # line separeted strings return as an array into packages
  readarray -t packages <<< $(whiptail --title ' Software selection ' \
    --separate-output --cancel-button 'Skip' \
    --checklist "Choose user's permissions" \
    20 50 $(( ${#PACKAGES[@]} / 3 )) \
    "${PACKAGES[@]}" \
    3>&1 1>&2 2>&3 3>&-)

  (for (( i = 0; i < ${#packages[@]}; i++ )); do
    sleep 0.8
    apt-get install -y -o APT::Status-Fd=2 ${packages[i]} 2>&1 1>&- \
      | while read line; do
          local apt_progress
          local regex

          regex="pmstatus:(${packages[i]}|dpkg-exec):([0-9]{1,3})\."

          [[ ${line} =~ ${regex} ]] \
            && apt_progress="$(( ${BASH_REMATCH[2]} / ${#packages[@]} ))"
          printf "%d\nXXX\n%s\nXXX\n" \
            "$(( ($i * 10000) / (${#packages[@]} * 100) + ${apt_progress} ))" \
            "Installing ${packages[i]}..."
        done
    printf "%d\nXXX\n%s\nXXX\n" \
      "$(( (($i +1) * 10000) / (${#packages[@]} * 100) ))" \
      "Installing ${packages[i]}... Done"
  done) \
    | whiptail --title " Software installation " \
               --gauge "Please wait while installing" \
               6 60 0
}

function setup_packages() {
  local packages

  # swap stdout and stderr from whiptail process and save its
  # line separeted strings return as an array into packages
  readarray -t packages <<< $(whiptail --title ' Software configuration ' \
    --separate-output --cancel-button 'Skip' \
    --checklist "Choose user's permissions" \
    20 50 $(( ${#DOTFILES[@]} / 3 )) \
    "${DOTFILES[@]}" \
    3>&1 1>&2 2>&3 3>&-)

  for (( i = 0; i < ${#packages[@]}; i++ )); do
    case package in
      neomutt )
        ;;
      neovim )
        ;;
      tmux )
        ;;
      zsh )
        ;;
      git )
        ;;
    esac
  done
}

function main() {
  local state
  local states

  state=MAIN_MENU
  states=["MAIN_MENU"
          "INSTALL_PACKAGES"
          "INSTALL_DOTFILES"
          "SETUP_PACKAGES"]

  while [[ true ]]; do
    case state in
      MAIN_MENU )
        state=main_menu
        ;;
      INSTALL_PACKAGES )
        state=install_packages
        ;;
      SETUP_PACKAGES )
        state=setup_packages
        ;;
      EXIT )
        break
        ;;
    esac
  done

  return 0
}

cd "${BASH_SOURCE[0]%/*}"
main "$@"

