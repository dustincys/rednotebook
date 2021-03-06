#!/bin/bash

# We cannot "set -e", because we need to check grep's exit code.
set -u

cd "$(dirname "$0")"
cd ../

py.test-2.7 tests || exit 1

pyflakes rednotebook tests | grep -v "undefined name '_'" | grep -v "rednotebook/external/"
NOTHING_FOUND=$?
if [ $NOTHING_FOUND == 0 ]; then
    echo Pyflake found errors.
    exit 1
fi

# Check for PEP8 errors:
# E402: module level import not at top of file
PEP8_OPTS="--max-line-length=110"
pep8 $PEP8_OPTS --exclude=external,journal.py rednotebook tests || exit 1
pep8 $PEP8_OPTS --ignore=E402 rednotebook/journal.py || exit 1

./dev/find-dead-code || exit 1

echo "All tests passed"
