#!/usr/bin/env bash

auth_path=$(dirname $(realpath $0))/apache-cgi/auth

userdesc() {
  desc=$(head -1 $1)
  echo ${desc#\# }
}

ord() {
  LC_CTYPE=C printf %d "'$1"
}

chr () {
  local val
  printf -v val %o "$1"; printf "\\$val"
}


echo -e "🔁 \x1B[1;37mSwitching users...\x1B[0m"
echo -e "👤 \x1B[1;36mCurrent user:\x1B[0m $(userdesc $auth_path/active_auth.conf)"
echo

echo -e "\x1B[1;36mUser types\x1B[0m"
files=($(/bin/ls $auth_path/*conf | grep -v active_auth.conf))
for index in ${!files[@]}; do
  file=${files[$index]}
  letterindex=$(chr $(( index + 97 )))
  echo -e "\x1B[1;37m$letterindex\x1B[0m) $(userdesc $file) (\x1B[1;36m$(basename $file)\x1B[0m)";
done

echo
echo -ne "\x1B[1;37mChoose a user type (or ctrl-C to cancel):\x1B[0m "

read -n 1 choice

choice_index=$(( $(ord $choice) - 97 ))

auth_file=${files[$choice_index]}

echo
echo -e "\x1B[1;36mUsing auth file \x1B[37m$auth_file\x1B[0m"
cp -v $auth_file $auth_path/active_auth.conf
echo -e "\x1B[1;36mReloading Apache configuration\x1Be[0m"
docker compose exec apache-cgi kill -USR1 1

echo -e "🎉 \x1B[1;36m Done!\x1B[0m"

