#! /bin/bash

RETURN_CODE=1

# ensure that cmus is running
if [[ $(pgrep -xl cmus | awk -F ' ' '{printf $2}') == "cmus" ]]; then
	ARTIST=$(cmus-remote -C status | awk -F" artist " 'NF > 1 {printf $2}')
	SONG=$(cmus-remote -C status | awk -F" title " 'NF > 1 {printf $2}')
	STATUS=$(cmus-remote -C status | awk -F"status " 'NF > 1 {printf $2}')
	if [[ "$STATUS" == "playing" ]]; then
		STATUS=
	elif [[ "$STATUS" == "paused" ]]; then
		STATUS=
	else
		STATUS=
	fi
	
	if [[ $(cmus-remote -C status | awk -F" repeat_current " 'NF > 1 {printf $2}') == "true" ]]; then
		REPEAT=
	elif [[ $(cmus-remote -C status | awk -F" repeat " 'NF > 1 {printf $2}') == "true" ]]; then
		REPEAT=
	else
		REPEAT=
	fi

	if [[ $(cmus-remote -C status | awk -F" shuffle " 'NF > 1 {printf $2}') == "true" ]]; then
		SHUFFLE=🔀
	else
		SHUFFLE=""
	fi

	# check number of arguments
	if (( $# == 0 )); then
		printf "$STATUS $ARTIST - $SONG $REPEAT $SHUFFLE"
		RETURN_CODE=0
	elif (( $# == 1 )); then
		case $1 in
			artist) 
				printf "$ARTIST"
				RETURN_CODE=0
				;;
			song)
				printf "$SONG"
				RETURN_CODE=0
				;;
			status)
				printf "$STATUS"
				RETURN_CODE=0
				;;
			repeat)
				printf "$REPEAT"
				RETURN_CODE=0
				;;
			shuffle)
				printf "$SHUFFLE"
				RETURN_CODE=0
				;;
		esac
	fi
fi

exit $RETURN_CODE

