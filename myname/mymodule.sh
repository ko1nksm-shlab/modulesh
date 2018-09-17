#!/bin/sh

myname_mymodule() {
  EXPORT foo a b c
  EXPORT bar
  EXPORT baz
  EXPORT change_var local_var
  EXPORT hello
}

myname_mymodule_foo() {
  echo ok: foo $#
}

myname_mymodule_bar() {
  echo ok: bar $#
}

myname_mymodule_baz() {
  echo ok: baz $#
}

myname_mymodule_change_var() {
  local_var=1
  global_var=1

  echo "local: $local_var, global: $global_var"
}

myname_mymodule_hello() {
  echo "hello $*"
}
