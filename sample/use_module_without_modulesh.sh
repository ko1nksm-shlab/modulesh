#!/bin/sh

# If you want to use module without modulesh

SCRIPTPATH="$PWD/$0"
SH_MODULE_DIR=${SCRIPTPATH%/*}/..

# shellcheck disable=SC1090
. "$SH_MODULE_DIR/myname/mymodule.sh"

hello() {
  _myname_mymodule_hello "$@"
}

hello world
