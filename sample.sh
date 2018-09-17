#!/bin/sh

# This is sample

SH_MODULE_DIR=${0%%/*}

# shellcheck disable=SC1090
. "$SH_MODULE_DIR/module.sh"

(
  IMPORT myname/mymodule
  mymodule_hello "module 1"
)

(
  IMPORT myname/mymodule:
  hello "module 2"
)

(
  IMPORT myname/mymodule:my
  my_hello "module 3"
)

(
  IMPORT myname/mymodule:my hello
  my_hello "module 4"
)

(
  IMPORT myname/mymodule hello:Hello
  Hello "module 5"
)
