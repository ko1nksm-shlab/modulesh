#!/bin/sh

myname_wrapper_mylib() {
  # shellcheck disable=SC1090
  . "${MODULE_SOURCE%/*}/_mylib.sh"
  EXPORT foo:mylib_foo
}
