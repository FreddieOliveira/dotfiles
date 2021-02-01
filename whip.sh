#!/usr/bin/env bash

function is_selected() {
  local pkg_name
  local file_name

  pkg_name=$1
  file_name=$2

  if grep -qs "^${pkg_name}$" $file_name; then
    echo ON
  else
    echo OFF
  fi
}

function is_dotfile_selected() {
  local pkg_name

  pkg_name=$1
  is_selected $pkg_name dotfiles.txt
}

function is_pkg_selected() {
  local pkg_name

  pkg_name=$1
  is_selected $pkg_name packages.txt
}

PACKAGES=('fasd' 'Find folder/files by frecency' $(is_pkg_selected fasd)
          'fzf' 'Fuzzy Finder' $(is_pkg_selected fzf)
          'gcc' 'GNU compiler' $(is_pkg_selected gcc)
          'gdb' 'GNU debugger' $(is_pkg_selected gdb)
          'gimp' 'GNU Image Manipulation Program' $(is_pkg_selected gimp)
          'neomutt' 'Patched Mutt mail client' $(is_pkg_selected neomutt)
          'neovim' 'Improved VIM' $(is_pkg_selected neovim)
          'tmux' 'Terminal multiplexer' $(is_pkg_selected tmux)
          'wine' 'Microsoft Windows environment' $(is_pkg_selected wine)
          'zsh' 'Z shell for Z warriors' $(is_pkg_selected zsh))

DOTFILES=('neomutt' 'Basic initial setup' $(is_dotfile_selected neomutt)
          'neovim' 'Config and plugins' $(is_dotfile_selected neovim)
          'tmux' 'Cool dotfile' $(is_dotfile_selected tmux)
          'zsh' 'Oh My Zsh' $(is_dotfile_selected zsh))

MAIN_MENU=('1. Install packages' 'Only install packages.'
           '2. Install dotfiles' 'Only install the dotfiles.'
           '3. Setup packages' 'Install plugins for the packages.')

function main_menu() {
    #"<-- Back" "Return to the main menu." \
  (whiptail --title " Main menu " --menu \
     "Choose an option" 25 78 16 \
     "${MAIN_MENU[@]}" \
     3>&1 1>&2 2>&3 3>&-)
}

function install_packages() {
  local packages

  # swap stdout and stderr from whiptail process and save its
  # line separeted strings return as an array into packages
  packages=($(whiptail --title ' Software selection ' \
    --separate-output --cancel-button 'Skip' \
    --checklist "Choose user's permissions" \
    20 50 $(( ${#PACKAGES[@]} / 3 )) \
    "${PACKAGES[@]}" \
    3>&1 1>&2 2>&3 3>&-))

  return 1

  # apt-get update 

  (for i in {0..$(( ${#packages[@]} - 1 ))}; do
    (( i > 0 )) && sleep 0.8
    printf "%d\nXXX\n%s\nXXX\n" \
      "$(( (i * 10000) / (${#packages[@]} * 100) ))" \
      "Installing ${packages[i]}..."
    apt-get install -y -o APT::Status-Fd=2 ${packages[i]} 2>&1 1>&- \
      | while read line; do
          local apt_progress
          local regex

          regex="pmstatus:.+:([0-9]{1,3})\."

          if [[ ${line} =~ ${regex} ]]; then
            apt_progress="$(( ${BASH_REMATCH[1]} / ${#packages[@]} ))"
            printf "%d\nXXX\n%s\nXXX\n" \
              "$(( (i * 10000) / (${#packages[@]} * 100) + apt_progress ))" \
              "Installing ${packages[i]}..."
          fi
        done
    printf "%d\nXXX\n%s\nXXX\n" \
      "$(( ((i + 1) * 10000) / (${#packages[@]} * 100) ))" \
      "Installing ${packages[i]}... Done"
  done) \
    | whiptail --title " Software installation " \
               --gauge "Please wait while installing" \
               6 60 0
}

function install_dotfiles() {
  local packages

  # swap stdout and stderr from whiptail process and save its
  # line separeted strings return as an array into packages
  packages=$(whiptail --title ' Software configuration ' \
    --separate-output --cancel-button 'Skip' \
    --checklist "Choose user's permissions" \
    20 50 $(( ${#DOTFILES[@]} / 3 )) \
    "${DOTFILES[@]}" \
    3>&1 1>&2 2>&3 3>&-)

  install $packages
}

function setup_packages() {
  local packages

  # swap stdout and stderr from whiptail process and save its
  # line separeted strings return as an array into packages
  packages=($(whiptail --title ' Software configuration ' \
    --separate-output --cancel-button 'Skip' \
    --checklist "Choose user's permissions" \
    20 50 $(( ${#DOTFILES[@]} / 3 )) \
    "${DOTFILES[@]}" \
    3>&1 1>&2 2>&3 3>&-))

  for i in {0..$(( ${#packages[@]} - 1 ))}; do
    case $package in
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
  local func

  func=main_menu  # initial function name

  while func=$($func); do
    func=${func#*. }   # delete the option number 
    func=${func,,}     # tolower
    func=${func// /_}  # substitute spaces for underscore
  done

  return 0
}

cd "${BASH_SOURCE[0]%/*}"
. install.sh
main "$@"

