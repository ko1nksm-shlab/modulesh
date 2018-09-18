#!/bin/sh

# shellcheck disable=SC2034
MODULESH_VERSION=0.1.0

# shellcheck disable=SC2039
_PROXY(){ local _; }
if _PROXY 2>/dev/null; then
  # checking $# in $func() to avoid https://bugs.debian.org/861743
  eval '_PROXY() {
    local func=${1%:*} to=${1#*:} local=""; shift
    [ $# -gt 0 ] && local="local $@; "
    eval "$func() { $local if [ \$# -gt 0 ]; then _$to \"\$@\"; else _$to; fi; }"
  }'
else
  eval 'function _PROXY {
    typeset func=${1%:*} to=${1#*:} local=""; shift
    [ $# -gt 0 ] && local="typeset $@; "
    eval "function $func { $local _$to \"\$@\"; }"
  }'
fi

_PROXY IMPORT \
  IFS module modname prefix exports export funcs func alias defname chunk

# Usage: IMPORT <module>[:<prefix>] [<func[:<alias>]>...]
_IMPORT() {
  path='' module=${1%%:*} prefix=${1#*:}
  case ${module%/*} in *[!a-zA-Z0-9]*)
    echo "ERROR: Namespace allows only character [a-zA-Z0-9] in $path" >&2
    exit 1
  esac
  case ${module##*/} in *[!a-zA-Z0-9_]*)
    echo "ERROR: Module allows only character [a-zA-Z0-9_] in $path" >&2
    exit 1
  esac

  [ "$module" = "$prefix" ] && prefix=${module#*/}
  shift

  chunk="$module/" modname=''
  while [ "$chunk" ]; do
    modname=${modname}${modname:+_}${chunk%%/*} chunk=${chunk#*/}
  done

  if eval [ -z "\${$modname+x}" ]; then
    if [ -z "$SH_MODULE_DIR" ]; then
      echo 'ERROR: SH_MODULE_DIR variable not set' >&2
      exit 1
    fi
    chunk=$SH_MODULE_DIR:
    while [ "$chunk" ]; do
      path=${chunk%%:*} chunk=${chunk#*:}
      [ "$path" ] && [ -f "$path/$module.sh" ] && break
    done
    if [ -z "$path" ]; then
      echo "ERROR: Module '$module' not found" >&2
      exit 1
    fi
    # shellcheck disable=SC1090
    . "$path/$module.sh"
    $modname
  fi

  IFS=' ' exports=''
  eval "exports=\$$modname"
  if [ $# -eq 0 ]; then
    eval "set -- $exports"
    for func in "$@"; do
      funcs="${funcs:-} ${func%%:*}"
    done
    eval "set -- $funcs"
  fi

  for func in "$@"; do
    case $func in
      *:*) alias=${func#*:} func=${func%:*} ;;
      *) alias=''
    esac
    [ "$alias" ] && defmodname=$alias || defmodname=${prefix}${prefix:+_}$func

    export="${exports#* $func}"
    if [ "$exports" = "$export" ]; then
      echo "ERROR: '$func' is not exported at $module." >&2
      exit 1
    fi

    chunk="${export%% *}:" export=''
    while [ "$chunk" ]; do
      export="${export} ${chunk%%:*}" chunk=${chunk#*:}
    done
    eval "_PROXY ${defmodname}:${modname}_${func} $export"
  done
}

# Usage: EXPORT <func> [<variable-modnames>...]
EXPORT() {
  IFS=':'
  eval "$modname=\"\${$modname:-} $*\""
}
