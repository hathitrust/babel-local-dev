#!/bin/bash

BABEL_HOME=$(dirname $(realpath $0))
dl_dir=$BABEL_HOME/stage-item
htid="$1"

if [[ -z "$HT_REPO_HOST" ]]; then cat <<EOT
Before running this, set HT_REPO_HOST to a username/host combination, for example:

  export HT_REPO_HOST=somebody@whatever.hathitrust.org
EOT
  exit 1
fi

if [[ -z "$htid" ]]; then cat <<EOT
Usage: $0 namespace.id
EOT
  exit 1
fi

path=$(docker compose run --rm stage-item bundle exec ruby item_path.rb "$htid")

echo

echo "🔽 Downloading $1 from $HT_REPO_HOST to $dl_dir"

scp "$HT_REPO_HOST":"$path" $dl_dir

docker compose run --rm stage-item bundle exec ruby stage_item.rb "$htid"

