#!/bin/bash

# if there is an \r error, go to notepad++, paste the script, ctrl+f and remove all \r
# use readarray for when user copies and pastes
allowedUsers=(root daemon bin sys sync games man lp mail news uucp proxy www-data backup list irc gnats nobody _apt ftp https)
nonAuthUsers=()
authedUsers=()

for user in `cut -d: -f1 /etc/passwd`; do
  if [[ ! ${allowedUsers[@]} =~ $user ]]; then
    echo "'$user'" is NOT authorized
    nonAuthUsers+=($user)
  else
    authedUsers+=($user)
  fi
done
echo
if (( ${#nonAuthUsers[@]} > 0 )); then # has sus user
  while :; do # inf loop til user_input = 1 or 5
    listIt () {
      for user in $@; do
        echo '  '$user
      done
    }
    e () { echo; echo $1; }
    PS3="> "
    select opt in "delete all non authorized users (runs the 'userdel -r user' cmd)" "list the SAFE users from the scan" "list the UNSAFE users from the scan" "list KNOWN safe users" "goto to main menu"; do
      case $REPLY in
        1)
          echo
          for user in ${nonAuthUsers[@]}; do
            echo deleting $user ...
            userdel -r $user || echo failed to delete
            wait
            echo deleted $user
          done
          break ;;
        2)
          e "accepted 'safe' user list:"
          listIt ${authedUsers[@]}
          break ;;
        3)
          e "detected 'unsafe' user list:"
          listIt ${nonAuthUsers[@]}
          break ;;
        4)
          e 'this is a immutable list of known safe default users:'
          listIt ${allowedUsers[@]}
          break ;;
        5) exit ;; # replace with goto main menu
        *)
      esac
    done
  done
else
  echo "accepted 'safe' user list: "${authedUsers[@]}
  echo
  echo No suspicious users detected
  read -rsn1 -p '...'
  exit # replace with goto main menu
fi
