#!/bin/env bash

exec_or_fail() {
    if command -v "${1}" >/dev/null 2>&1; then
        "${@}" 2>/dev/null
        return "${?}"
    fi
    # error
    return 1
}

handle_unsupported_extensions() {
    if [ -d "${file_path}" ] && command -v tree >/dev/null 2>&1; then
        tree -C "${file_path}" | head -100
    else
        ls -alh "${file_path}"
        echo ''
        exec_or_fail file "${file_path}"
    fi
}

handle_supported_extensions() {
    local file_path="${1}"
    local file_extension="${2}"

    case "${file_extension}" in
        ## Image
        bmp|gif|jpg|jpeg|png)
            exec_or_fail img2txt -f utf8 -d none -g 0.6 \
              -W $(("${COLUMNS}" - 6)) "${file_path}" && return 0
            ;;

        ## Archive
        a|ace|alz|apk|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
        rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|z|zip)
            exec_or_fail atool --list -- "${file_path}" && return 0
            exec_or_fail bsdtar --list --file "${file_path}" && return 0
            ;;
        rar)
            ## Avoid password prompt by providing empty password
            exec_or_fail unrar lt -p- -- "${file_path}" && return 0
            ;;
        7z)
            ## Avoid password prompt by providing empty password
            exec_or_fail 7z l -p -- "${file_path}" && return 0
            ;;

        ## PDF
        pdf)
            ## Preview as text conversion
            exec_or_fail pdftotext -l 10 -nopgbrk -q -- "${file_path}" - | \
              fmt -w "${PV_WIDTH}" && return 0
            exec_or_fail mutool draw -F txt -i -- "${file_path}" 1-10 | \
              fmt -w "${PV_WIDTH}" && return 0
            exec_or_fail exiftool "${file_path}" && return 0
            ;;

        ## BitTorrent
        torrent)
            exec_or_fail transmission-show -- "${file_path}" && return 0
            ;;

        ## OpenDocument
        odt|ods|odp|sxw)
            ## Preview as text conversion
            exec_or_fail odt2txt "${file_path}" && return 0
            ## Preview as markdown conversion
            exec_or_fail pandoc -s -t markdown -- "${file_path}" && return 0
            ;;

        ## XLS
        xls)
            ## Preview as csv conversion
            ## xls2csv comes with catdoc:
            ##   http://www.wagner.pp.ru/~vitus/software/catdoc/
            exec_or_fail xls2csv -- "${file_path}" && return 0
            ;;
        xlsx)
            ## Preview as csv conversion
            ## Uses: https://github.com/dilshod/xlsx2csv
            exec_or_fail xlsx2csv -- "${file_path}" && return 0
            ;;

        ## HTML
        htm|html|xhtml)
            ## Preview as text conversion
            exec_or_fail w3m -dump "${file_path}" && return 0
            exec_or_fail lynx -dump -- "${file_path}" && return 0
            exec_or_fail elinks -dump "${file_path}" && return 0
            exec_or_fail pandoc -s -t markdown -- "${file_path}" && return 0
            ;;

        ## JSON
        json)
            exec_or_fail jq --color-output . "${file_path}" && return 0
            exec_or_fail python -m json.tool -- "${file_path}" && return 0
            ;;

        ## Direct Stream Digital/Transfer (DSDIFF)
        ## and wavpack aren't detecte dby file(1)
        dff|dsf|wv|wvc)
            exec_or_fail mediainfo "${file_path}" && return 0
            exec_or_fail exiftool "${file_path}" && return 0
            ;;

        * )
            exec_or_fail bat --style=numbers --color=always \
                --line-range=:200 "${file_path}" && return 0
            ;;
    esac
    # error
    return 1
}

main() {
    local file_path="${1}"
    local file_extension="$(tr '[:upper:]' '[:lower:]' <<<"${file_path##*.}")"

    handle_supported_extensions "${file_path}" "${file_extension}" || \
        handle_unsupported_extensions
}

shopt -s checkwinsize; (:);
main "${@}"
