#!/bin/bash

cat <<EOT
Checking out into $PWD

What should the git URL be?
 [1] HTTPS: https://github.com/hathitrust (default)
 [2] SSH:   git@github.com:hathitrust

Enter 1, 2, or ctrl-C to abort.
EOT

read proto

GIT_BASE="https://github.com/hathitrust"

if [[ "$proto" == "2" ]]; then
  GIT_BASE="git@github.com:hathitrust"
fi

git clone --recurse-submodules $GIT_BASE/imgsrv
git clone --recurse-submodules $GIT_BASE/imgsrv-sample-data ./sample-data
git clone --recurse-submodules $GIT_BASE/catalog
git clone --recurse-submodules $GIT_BASE/common
git clone --recurse-submodules -b DEV-663-docker $GIT_BASE/pt
git clone --recurse-submodules -b DEV-663-docker $GIT_BASE/ssd
git clone --recurse-submodules $GIT_BASE/hathitrust_catalog_indexer
git clone --recurse-submodules $GIT_BASE/slip
git clone --recurse-submodules -b DEV-661-docker $GIT_BASE/lss_solr_configs

echo "CURRENT_USER=$(id -u):$(id -g)" >> .env
echo "APACHE_RUN_USER=$(id -u)" >> .env
echo "APACHE_RUN_GROUP=$(id -g)" >> .env

# Do we need these separately?
# git clone $GIT_BASE/mdp-lib.git
# git clone $GIT_BASE/slip-lib.git
# git clone $GIT_BASE/plack-lib.git
