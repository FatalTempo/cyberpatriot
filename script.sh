#!/bin/bash

# if there is an \r error, go to notepad++, paste the script, ctrl+f and remove all \r
# use readarray for when user copies and pastes
e () { echo; echo $1; }
listIt () { # avoids being DRY
  for user in $@; do
    echo '  '$user
  done
}
allowedUsers=(root daemon bin sys sync games man lp mail news uucp proxy www-data backup list irc gnats nobody _apt ftp https avahi saned)
nonAuthUsers=()
authedUsers=()

echo "detected 'unsafe' user list:"
for user in `cut -d: -f1 /etc/passwd`; do
  if [[ ! ${allowedUsers[@]} =~ $user ]]; then
    echo '  '$user
    nonAuthUsers+=($user)
  else
    authedUsers+=($user)
  fi
done

e 'check for accuracy of course.'

if (( ${#nonAuthUsers[@]} > 0 )); then # has sus user
  while :; do # inf loop til user_input = 1 or 5
    PS3="> "
    select opt in "delete all non authorized users (runs the 'userdel -r user' cmd)" "list the SAFE users from the scan" "list the UNSAFE users from the scan" "list KNOWN safe users" "goto to main menu"; do
      case $REPLY in
        1)
          e
          for user in ${nonAuthUsers[@]}; do
            userdel -r $user
            wait
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
