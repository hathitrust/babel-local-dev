#!/usr/bin/env bash

if [[ "$1" == "SSH" ]]; then
  proto=$1;
fi

if [[ -z $proto ]]; then
  cat <<EOT
Checking out into $PWD

What should the git URL be?
 [1] HTTPS: https://github.com/hathitrust (default)
 [2] SSH:   git@github.com:hathitrust
EOT

  echo -n "Your choice? [1]: "
  read -n 1 proto
fi

GIT_BASE="https://github.com/hathitrust"

if [[ "$proto" == "2" ]]; then
  GIT_BASE="git@github.com:hathitrust"
fi

echo
echo
echo 📥 Cloning repositories via $GIT_BASE...
echo

git clone --recurse-submodules $GIT_BASE/imgsrv
git clone --recurse-submodules $GIT_BASE/imgsrv-sample-data ./sample-data
git clone --recurse-submodules $GIT_BASE/catalog
git clone --recurse-submodules $GIT_BASE/common
git clone --recurse-submodules $GIT_BASE/pt
git clone --recurse-submodules $GIT_BASE/mb
git clone --recurse-submodules $GIT_BASE/ls
git clone --recurse-submodules $GIT_BASE/ping
git clone --recurse-submodules $GIT_BASE/ssd
git clone --recurse-submodules $GIT_BASE/hathitrust_catalog_indexer
git clone --recurse-submodules $GIT_BASE/slip
git clone --recurse-submodules $GIT_BASE/lss_solr_configs
git clone --recurse-submodules $GIT_BASE/mdp-lib
git clone --recurse-submodules $GIT_BASE/plack-lib
git clone --recurse-submodules $GIT_BASE/slip-lib
git clone --recurse-submodules $GIT_BASE/mdp-web
git clone --recurse-submodules $GIT_BASE/ptsearch-solr
git clone --recurse-submodules $GIT_BASE/firebird-common

echo 
echo 🍃 Setting up the environment...
echo 

cat <<EOT | tee .env
CURRENT_USER="$(id -u):$(id -g)"
APACHE_RUN_USER="$(id -u)"
APACHE_RUN_GROUP="$(id -g)"
BABEL_HOME="$(dirname $(realpath $0))"

EOT

echo
echo 💎 Setting up stage_item...
echo

docker compose run traject bundle install
docker compose run stage-item bundle install

echo
echo 🐦‍🔥 Building firebird...
echo

docker compose run node /htapps/babel/firebird-common/bin/build.sh
docker compose run node /htapps/babel/pt/bin/build.sh

echo
echo 🎉 Done!
