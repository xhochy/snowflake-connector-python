#!/bin/bash -e
#
# Run Travis Tests
#

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -o pipefail
if [ "$TRAVIS_OS_NAME" == "osx" ]; then
    TIMEOUT_CMD=("gtimeout" "-s" "SIGUSR1" "3600s")
else
    TIMEOUT_CMD=("timeout" "-s" "SIGUSR1" "3600s")
fi
source ./venv/bin/activate
ret=0
if [ -n "$SNOWFLAKE_AZURE" ]; then
  echo "Running Azure tests only..."
  ${TIMEOUT_CMD[@]} py.test -vvv --cov=snowflake.connector \
  --cov-report=xml:python_connector_${TRAVIS_PYTHON_VERSION}_coverage.xml \
  -m azure test || ret=$?
else
  echo "Running regular tests..."
  ${TIMEOUT_CMD[@]} py.test -vvv --cov=snowflake.connector \
  --cov-report=xml:python_connector_${TRAVIS_PYTHON_VERSION}_coverage.xml \
  test || ret=$?
fi

# TIMEOUT or SUCCESS
[ $ret != 124 -a $ret != 0 ] && exit 1 || exit 0
