#!/bin/sh

# This is sample

SCRIPTPATH="$PWD/$0"
SH_MODULE_DIR=${SCRIPTPATH%/*}/..

# shellcheck disable=SC1090
. "$SH_MODULE_DIR/module.sh"

IMPORT myname/wrapper/mylib
myname_wrapper_mylib_foo
