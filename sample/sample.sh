#!/bin/sh

# This is sample

SCRIPTPATH="$PWD/$0"
SH_MODULE_DIR=${SCRIPTPATH%/*}/..

# shellcheck disable=SC1090
. "$SH_MODULE_DIR/module.sh"

(
  IMPORT myname/mymodule
  myname_mymodule_hello "mymodule_hello"
)

(
  IMPORT myname/mymodule:
  hello "hello"
)

(
  IMPORT myname/mymodule:my
  my_hello "my_hello"
)

(
  IMPORT myname/mymodule:my hello
  my_hello "my_hello:2"
)

(
  IMPORT myname/mymodule hello:Hello
  Hello "Hello"
)

(
  IMPORT myname/sub/foo
  myname_sub_foo_hello "Hello"
)
