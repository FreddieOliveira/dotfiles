#!/usr/bin/env bash

function is_selected() {
  local pkg_name=$1
  local file_name=$2

  if grep -qs "^${pkg_name}$" $file_name; then
    echo ON
  else
    echo OFF
  fi
}

function is_dotfile_selected() {
  local pkg_name=$1

  is_selected $pkg_name dotfiles.txt
}

function is_pkg_selected() {
  local pkg_name=$1

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

function install_packages() {
  local packages

  # swap stdout and stderr from whiptail process and save its
  # line separeted strings return as an array into packages
  packages=($(whiptail --title ' Software selection ' \
    --separate-output --cancel-button 'Skip' \
    --checklist "Choose packages to be installed'" \
    20 50 $(( ${#PACKAGES[@]} / 3 )) \
    "${PACKAGES[@]}" \
    3>&1 1>&2 2>&3 3>&-))

  (( $? != 0 || ${#packages[@]} == 0 )) && return $?

  # apt-get update 
  (printf "XXX\n%d\n%s\nXXX\n" "0" "Updating mirrors..."
   apt-get update -y -o APT::Status-Fd=2 2>&1 1>/dev/null \
     | while read line; do
         local regex apt_progress last_progress

         regex="file ([0-9]+) of ([0-9]+)"

         if [[ $line =~ $regex ]]; then
	   apt_progress="$(( ((${BASH_REMATCH[1]} - 1) * 100) / ${BASH_REMATCH[2]} ))"
           (( apt_progress < last_progress )) && apt_progress=$last_progress
           last_progress=$apt_progress
           printf "XXX\n%d\n%s\nXXX\n" $apt_progress "Updating mirrors..."
         fi
       done) \
  | whiptail --title " Software installation " \
             --gauge "Please wait while updating" \
             6 60 0

  # apt-get install
  (for (( i = 0; i < ${#packages[@]}; i++ )); do
    (( i > 0 )) && sleep 0.3
    printf "XXX\n%d\n%s\nXXX\n" \
      "$(( (i * 100) / ${#packages[@]} ))" \
      "Downloading ${packages[i]}..."
    apt-get install -y -o APT::Status-Fd=2 ${packages[i]} 2>&1 1>/dev/null \
      | while read line; do
          local regex_1 regex_2 apt_progress

          regex_1="dlstatus:.+:([0-9]{1,3})\."
          regex_2="pmstatus:.+:([0-9]{1,3})\."

          if [[ $line =~ $regex_1 ]]; then
            apt_progress="$(( ${BASH_REMATCH[1]} / ${#packages[@]} ))"
            printf "XXX\n%d\n%s\nXXX\n" \
              "$(( (i * 100) / ${#packages[@]} + apt_progress / 2 ))" \
              "Downloading ${packages[i]}..."
          elif [[ $line =~ $regex_2 ]]; then
            apt_progress="$(( ${BASH_REMATCH[1]} / ${#packages[@]} ))"
            printf "XXX\n%d\n%s\nXXX\n" \
              "$(( (i * 100 + 50) / ${#packages[@]} + apt_progress / 2 ))" \
              "Installing ${packages[i]}..."
          fi
        done
    printf "XXX\n%d\n%s\nXXX\n" \
      "$(( ((i + 1) * 100) / ${#packages[@]} ))" \
      "Installing ${packages[i]}... Done"
    sleep 0.4
  done) \
    | whiptail --title " Software installation " \
               --gauge "Please wait while installing" \
               6 60 0
}

function install_dotfiles() {
  local packages_aux packages

  # swap stdout and stderr from whiptail process and save its
  # line separeted strings return as an array into packages
  packages_aux=$(whiptail --title ' Software configuration ' \
    --separate-output --cancel-button 'Skip' \
    --checklist "Install dotfiles for selected packages" \
    20 50 $(( ${#DOTFILES[@]} / 3 )) \
    "${DOTFILES[@]}" \
    3>&1 1>&2 2>&3 3>&-)

  (( $? != 0 )) || [[ $packages_aux == '' ]] && return $?

  for pkg in $packages_aux; do
    packages=$pkg,$packages
  done

  install $packages
}

function setup_packages() {
  local packages

  # swap stdout and stderr from whiptail process and save its
  # line separeted strings return as an array into packages
  packages=($(whiptail --title ' Software configuration ' \
    --separate-output --cancel-button 'Skip' \
    --checklist "Install plugins for selected packages" \
    20 50 $(( ${#DOTFILES[@]} / 3 )) \
    "${DOTFILES[@]}" \
    3>&1 1>&2 2>&3 3>&-))

  (( $? != 0 || ${#packages[@]} == 0 )) && return $?

  for (( i = 0; i < ${#packages[@]}; i++ )); do
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

function setup_wizard() {
  install_packages
  install_dotfiles
  setup_packages
  return 0
}
