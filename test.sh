#!/bin/sh

set -e

SH_MODULE_DIR=${0%%/*}
SELF=$0

main() {
  [ $# -eq 0 ] && run_tests
  [ "$1" = -h ] || [ "$1" = --help ] && usage
  if [ "$1" = -a ] || [ "$1" = --all ]; then
    set -- dash bash zsh ksh mksh yash posh 'busybox ash'
  fi
  for shell in "$@"; do
    if which "${shell%% *}" >/dev/null; then
      $shell "$0"
    else
      echo "Skip: $shell not found"
    fi
  done
}

usage() {
cat<<HERE
Run module.sh tests

Usage: ${0##*/} [-a | --all | -h | --help ] [<shell>...]

If specified -a/--all option, tests all supported shell.
HERE
exit
}

run_tests() {
  # shellcheck disable=SC2009
  printf 'Run: %s\n' "$(ps -o pid,args= | sed -nE "/^ *$$/p")"
  # shellcheck disable=SC1090
  . "$SH_MODULE_DIR/module.sh"
  for test in $(tests); do
    ( $test; return "${ERROR:-0}") || FAILED=1
  done
  [ "${FAILED:-}" ] && echo failed || echo success
  exit
}

tests() {
  while IFS= read -r line; do
    case "$line" in
      test_*) echo "${line%\(*}"
    esac
  done < "$SELF"
}

exist_function() {
  if [ "${POSH_VERSION:-}" ]; then
    (unset -f "$1") 2>/dev/null
  else
    eval type "$1" >/dev/null 2>/dev/null
  fi
}

not() { ! "$@"; }

if [ "$(eval echo -n)" ]; then
  ok() { printf '.'; }
  ng() { printf '!'; ERROR=1; }
else
  ok() { eval echo -n '.'; }
  ng() { eval echo -n '!'; ERROR=1; }
fi

t() {
  if "$@"; then
    ok
  else
    ng
  fi
}
# Imports all functions from module with default prefix
test_import_all_with_default_prefix() {
  IMPORT myname/mymodule
  t [ "$(mymodule_foo "1 2" "3 4")" = "ok: foo 2" ]
  t [ "$(mymodule_bar)" = "ok: bar 0" ]
  t [ "$(mymodule_baz)" = "ok: baz 0" ]
}

# Imports all functions from module without prefix
test_import_all_without_prefix() {
  IMPORT myname/mymodule:
  t [ "$(foo)" = "ok: foo 0" ]
  t [ "$(bar)" = "ok: bar 0" ]
  t [ "$(baz)" = "ok: baz 0" ]
}

# Imports all functions from module with prefix
test_import_all_with_prefix() {
  IMPORT myname/mymodule:sh
  t [ "$(sh_foo)" = "ok: foo 0" ]
  t [ "$(sh_bar)" = "ok: bar 0" ]
  t [ "$(sh_baz)" = "ok: baz 0" ]
}

# Imports specified functions from module with default prefix
test_import_default_prefix() {
  IMPORT myname/mymodule foo
  t [ "$(mymodule_foo)" = "ok: foo 0" ]
  t not exist_function mymodule_bar
  t not exist_function mymodule_baz
}


# Imports specified functions from module without prefix
test_import_without_prefix() {
  IMPORT myname/mymodule: foo
  t [ "$(foo)" = "ok: foo 0" ]
  t not exist_function mymodule_bar
  t not exist_function mymodule_baz
  t not exist_function bar
  t not exist_function baz
}

# Imports specified functions from module with prefix
test_import_with_prefix() {
  IMPORT myname/mymodule:sh foo
  t [ "$(sh_foo)" = "ok: foo 0" ]
  t not exist_function mymodule_bar
  t not exist_function mymodule_baz
  t not exist_function sh_bar
  t not exist_function sh_baz
}

# Imports specified functions from module with alias
test_import_with_alias() {
  IMPORT myname/mymodule:sh foo bar:my_bar baz:baz
  t [ "$(sh_foo)" = "ok: foo 0" ]
  t not exist_function mymodule_foo
  t [ "$(my_bar)" = "ok: bar 0" ]
  t not exist_function sh_bar
  t [ "$(baz)" = "ok: baz 0" ]
  t not exist_function sh_baz
}

test_change_var() {
  IMPORT myname/mymodule
  local_var='' global_var=''
  mymodule_change_var >/dev/null
  t [ "$local_var" = "" ]
  t [ "$global_var" = "1" ]
}

test_using_other_module() {
  IMPORT myname/using_other_module
  t [ "$(using_other_module_hello "using_other_module")" = "hello using_other_module" ]
}

test_myname_sub_foo() {
  IMPORT myname/sub/foo
  t [ "$(foo_hello)" = "sub foo" ]
}

main "$@"
