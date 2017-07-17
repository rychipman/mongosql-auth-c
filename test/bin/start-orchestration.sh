#!/bin/bash

. "$(dirname $0)/platforms.sh"
. "$(dirname $0)/prepare-shell.sh"

(
    set -o errexit
    echo "bootstrapping mongo-orchestration..."

    AUTH=${AUTH:-noauth}
    SSL=${SSL:-nossl}
    TOPOLOGY=${TOPOLOGY:-server}
    STORAGE_ENGINE=${STORAGE_ENGINE}
    MONGODB_VERSION=${MONGODB_VERSION:-latest}

    mkdir -p $MONGO_ORCHESTRATION_HOME
    cp -r $PROJECT_DIR/test/resources/orchestration/* $MONGO_ORCHESTRATION_HOME

    DL_START=$(date +%s)
    DIR=$(dirname $0)
    # Functions to fetch MongoDB binaries
    . $DIR/download-mongodb.sh

    get_distro
    get_mongodb_download_url_for "$DISTRO" "$MONGODB_VERSION"
    echo "downloading mongodb $MONGODB_VERSION for $DISTRO..."
    download_and_extract "$MONGODB_DOWNLOAD_URL" "$EXTRACT"
    echo "done downloading mongodb"

    DL_END=$(date +%s)
    MO_START=$(date +%s)

    ORCHESTRATION_FILE="basic"
    if [ "$AUTH" = "auth" ]; then
      ORCHESTRATION_FILE="auth"
    fi

    if [ "$SSL" != "nossl" ]; then
       ORCHESTRATION_FILE="${ORCHESTRATION_FILE}-ssl"
    fi

    # Storage engine config files do not exist for different topology, auth, or ssl modes.
    if [ ! -z "$STORAGE_ENGINE" ]; then
      ORCHESTRATION_FILE="$STORAGE_ENGINE"
    fi

    export ORCHESTRATION_FILE="$MONGO_ORCHESTRATION_HOME/configs/${TOPOLOGY}s/${ORCHESTRATION_FILE}.json"
    export ORCHESTRATION_URL="http://localhost:8889/v1/${TOPOLOGY}s"

    echo From shell `date` > $MONGO_ORCHESTRATION_HOME/server.log

    cd "$MONGO_ORCHESTRATION_HOME"
    # Setup or use the existing virtualenv for mongo-orchestration
    if [ -f venv/bin/activate ]; then
      . venv/bin/activate
    elif [ -f venv/Scripts/activate ]; then
      . venv/Scripts/activate
    elif virtualenv --system-site-packages venv || python -m virtualenv --system-site-packages venv; then
      if [ -f venv/bin/activate ]; then
        . venv/bin/activate
      elif [ -f venv/Scripts/activate ]; then
        . venv/Scripts/activate
      fi
      # Install from github otherwise mongo-orchestration won't download simplejson
      # with Python 2.6.
      pip install --upgrade 'git+git://github.com/mongodb/mongo-orchestration@master'
      pip freeze
    fi
    cd -

    for filename in $(find -L $MONGO_ORCHESTRATION_HOME -name \*.json); do
        perl -i -pe "s|PROJECT_DIR_REPLACEMENT_TOKEN|$PROJECT_DIR|" $filename
    done

    echo "{ \"releases\": { \"default\": \"$MONGODB_BINARIES\" }}" > $MONGO_ORCHESTRATION_HOME/orchestration.config

    ORCHESTRATION_ARGUMENTS="-e default -f $MONGO_ORCHESTRATION_HOME/orchestration.config --socket-timeout-ms=60000 --bind=127.0.0.1 --enable-majority-read-concern"
    if [ "Windows_NT" = "$OS" ]; then # Magic variable in cygwin
      ORCHESTRATION_ARGUMENTS="$ORCHESTRATION_ARGUMENTS -s wsgiref"
    fi

    # Forcibly kill the process listening on port 8889, most likey a wild
    # mongo-orchestration left running from a previous task.
    if [ "Windows_NT" = "$OS" ]; then # Magic variable in cygwin
      OLD_MO_PID=$(netstat -ano | grep ':8889 .* LISTENING' | awk '{print $5}' | tr -d '[:space:]')
      if [ ! -z "$OLD_MO_PID" ]; then
        taskkill /F /T /PID "$OLD_MO_PID" || true
      fi
    else
      OLD_MO_PID=$(lsof -t -i:8889 || true)
      if [ ! -z "$OLD_MO_PID" ]; then
        kill -9 "$OLD_MO_PID" || true
      fi
    fi

    cd $MONGO_ORCHESTRATION_HOME
    nohup mongo-orchestration $ORCHESTRATION_ARGUMENTS start > mongo-orchestration.log 2>&1 < /dev/null &

    ls -la $MONGO_ORCHESTRATION_HOME

    sleep 15
    curl http://localhost:8889/ --silent --max-time 120 --fail

    sleep 5

    pwd
    curl --silent --data @"$ORCHESTRATION_FILE" "$ORCHESTRATION_URL" --max-time 300 --fail > tmp.json
    URI=$(python -c 'import sys, json; j=json.load(open("tmp.json")); print(j["mongodb_auth_uri" if "mongodb_auth_uri" in j else "mongodb_uri"])' | tr -d '\r')
    echo 'MONGODB_URI: "'$URI'"' > $MONGO_ORCHESTRATION_HOME/mo-expansion.yml
    echo "Cluster URI: $URI"

    MO_END=$(date +%s)
    MO_ELAPSED=$(expr $MO_END - $MO_START)
    DL_ELAPSED=$(expr $DL_END - $DL_START)
    cat <<EOT >> $MONGO_ORCHESTRATION_HOME/results.json
    {"results": [
      {
        "status": "PASS",
        "test_file": "Orchestration",
        "start": $MO_START,
        "end": $MO_END,
        "elapsed": $MO_ELAPSED
      },
      {
        "status": "PASS",
        "test_file": "Download MongoDB",
        "start": $DL_START,
        "end": $DL_END,
        "elapsed": $DL_ELAPSED
      }
    ]}
EOT

    echo "done bootstrapping mongo-orchestration"

) > $LOG_FILE 2>&1

print_exit_msg
