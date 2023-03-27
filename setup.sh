#!/bin/bash

echo "Checking out into $PWD - enter to continue, ctrl-C to abort"

read

git clone --recurse-submodules git@github.com:hathitrust/imgsrv
git clone --recurse-submodules git@github.com:hathitrust/imgsrv-sample-data
git clone --recurse-submodules git@github.com:hathitrust/catalog
git clone --recurse-submodules git@github.com:hathitrust/common
git clone --recurse-submodules git@github.com:hathitrust/pt
git clone --recurse-submodules git@github.com:hathitrust/ssd
git clone --recurse-submodules git@github.com:hathitrust/hathitrust_catalog_indexer
git clone --recurse-submodules -b DEV-667-stage-item git@github.com:hathitrust/ht-pairtree
git clone --recurse-submodules -b DEV-661-docker git@github.com:hathitrust/slip
git clone --recurse-submodules -b DEV-661-docker git@github.com:hathitrust/lss_solr_configs

# Directories the web server needs to write to under /htapps/babel
mkdir cache logs
chmod a+w cache logs

# Directory solr needs to write to
chmod a+w lss_solr_configs/lss-dev/core-x/data

# Not yet covered in the apache config although maybe it was before
# git clone git@github.com:hathitrust/pt.git

# Do we need these separately?
# git clone git@github.com:hathitrust/mdp-lib.git
# git clone git@github.com:hathitrust/slip-lib.git
# git clone git@github.com:hathitrust/plack-lib.git
