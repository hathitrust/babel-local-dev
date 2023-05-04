#!/bin/bash

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


echo -e "🔁 \e[1;37mSwitching users...\e[0m"
echo -e "👤 \e[1;36mCurrent user:\e[0m $(userdesc $auth_path/active_auth.conf)"
echo

echo -e "\e[1;36mUser types\e[0m"
files=($(/bin/ls $auth_path/*conf | grep -v active_auth.conf))
for index in ${!files[@]}; do
  file=${files[$index]}
  letterindex=$(chr $(( index + 97 )))
  echo -e "\e[1;37m$letterindex\e[0m) $(userdesc $file) (\e[1;36m$(basename $file)\e[0m)";
done

echo
echo -ne "\e[1;37mChoose a user type (or ctrl-C to cancel):\e[0m "

read -N 1 choice

choice_index=$(( $(ord $choice) - 97 ))

auth_file=${files[$choice_index]}

echo
echo -e "\e[1;36mUsing auth file \e[37m$auth_file\e[0m"
cp -v $auth_file $auth_path/active_auth.conf
echo -e "\e[1;36mReloading Apache configuration\e[0m"
docker compose exec apache-cgi kill -USR1 1

echo -e "🎉 \e[1;36m Done!\e[0m"

