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

git clone --recurse-submodules -b DEV-667-remove-docker-compose $GIT_BASE/imgsrv
git clone --recurse-submodules $GIT_BASE/imgsrv-sample-data ./sample-data
git clone --recurse-submodules $GIT_BASE/catalog
git clone --recurse-submodules $GIT_BASE/common
git clone --recurse-submodules -b DEV-663-docker $GIT_BASE/pt
git clone --recurse-submodules -b DEV-663-docker $GIT_BASE/ssd
git clone --recurse-submodules $GIT_BASE/hathitrust_catalog_indexer
git clone --recurse-submodules -b DEV-667-stage-item $GIT_BASE/ht-pairtree
git clone --recurse-submodules -b DEV-661-docker $GIT_BASE/slip
git clone --recurse-submodules -b DEV-661-docker $GIT_BASE/lss_solr_configs

# Directories the web server needs to write to under /htapps/babel
mkdir cache logs
chmod a+w cache logs

# Directory solr needs to write to
chmod a+w lss_solr_configs/lss-dev/core-x/data

# Not yet covered in the apache config although maybe it was before
# git clone $GIT_BASE/pt.git

# Do we need these separately?
# git clone $GIT_BASE/mdp-lib.git
# git clone $GIT_BASE/slip-lib.git
# git clone $GIT_BASE/plack-lib.git
