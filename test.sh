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
  printf 'Run: %s\n' "$(ps -o pid,args= | grep ^$$ | cut -d' ' -f 2-)"
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

test() {
  if "$@"; then
    ok
  else
    ng
  fi
}
# Imports all functions from module with default prefix
test_import_all_with_default_prefix() {
  IMPORT myname/mymodule
  test [ "$(mymodule_foo)" = "ok: foo 0" ]
  test [ "$(mymodule_bar)" = "ok: bar 0" ]
  test [ "$(mymodule_baz)" = "ok: baz 0" ]
}

# Imports all functions from module without prefix
test_import_all_without_prefix() {
  IMPORT myname/mymodule:
  test [ "$(foo)" = "ok: foo 0" ]
  test [ "$(bar)" = "ok: bar 0" ]
  test [ "$(baz)" = "ok: baz 0" ]
}

# Imports all functions from module with prefix
test_import_all_with_prefix() {
  IMPORT myname/mymodule:sh
  test [ "$(sh_foo)" = "ok: foo 0" ]
  test [ "$(sh_bar)" = "ok: bar 0" ]
  test [ "$(sh_baz)" = "ok: baz 0" ]
}

# Imports specified functions from module with default prefix
test_import_default_prefix() {
  IMPORT myname/mymodule foo
  test [ "$(mymodule_foo)" = "ok: foo 0" ]
  test not exist_function mymodule_bar
  test not exist_function mymodule_baz
}


# Imports specified functions from module without prefix
test_import_without_prefix() {
  IMPORT myname/mymodule: foo
  test [ "$(foo)" = "ok: foo 0" ]
  test not exist_function mymodule_bar
  test not exist_function mymodule_baz
  test not exist_function bar
  test not exist_function baz
}

# Imports specified functions from module with prefix
test_import_with_prefix() {
  IMPORT myname/mymodule:sh foo
  test [ "$(sh_foo)" = "ok: foo 0" ]
  test not exist_function mymodule_bar
  test not exist_function mymodule_baz
  test not exist_function sh_bar
  test not exist_function sh_baz
}

# Imports specified functions from module with alias
test_import_with_alias() {
  IMPORT myname/mymodule:sh foo bar:my_bar baz:baz
  test [ "$(sh_foo)" = "ok: foo 0" ]
  test not exist_function mymodule_foo
  test [ "$(my_bar)" = "ok: bar 0" ]
  test not exist_function sh_bar
  test [ "$(baz)" = "ok: baz 0" ]
  test not exist_function sh_baz
}

test_change_var() {
  IMPORT myname/mymodule
  local_var='' global_var=''
  mymodule_change_var >/dev/null
  test [ "$local_var" = "" ]
  test [ "$global_var" = "1" ]
}

main "$@"