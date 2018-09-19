#!/bin/sh

# This is sample

SH_MODULE_DIR=${0%%/*}

# shellcheck disable=SC1090
. "$SH_MODULE_DIR/module.sh"

(
  IMPORT myname/mymodule
  mymodule_hello "mymodule_hello"
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
  foo_hello "Hello"
)
