# module.sh

Tiny module system for POSIX compatible shell script.

[![Build Status](https://travis-ci.org/ko1nksm/modulesh.svg?branch=master)](https://travis-ci.org/ko1nksm/modulesh)

Supported shell: `dash`, `bash`, `zsh`, `ksh`, `mksh`, `yash`, `posh`, `busybox (ash)`

## Using module

```shell
  SH_MODULE_DIR=<module base directory>
  . "$SH_MODULE_DIR/module.sh"

  IMPORT namespaceA/moduleA1:a1
  a1_hello "moduleA1"

  IMPORT namespaceA/moduleA2:a2
  a2_hello "moduleA2"
```

example module directory

```
Module base directory ($SH_MODULE_DIR)
├ module.sh
│
├ namespaceA
│  ├ moduleA1.sh
│  └ moduleA2
│      └ moduleA2.sh
└ namespaceB
    ├ moduleB1.sh
    └ moduleB2.sh
```

## Create module

example module: `namesapceA/moduleA1.sh`

```shell
#!/bin/sh

# initializer: Invoked by module.sh to export functions
namesapceA_moduleA1() {
  # localize var for all function
  DEFAULT_LOCAL var B1

  # export hello function and localize var1
  EXPORT hello var1

  # Using other module (Do not use IMPORT in module)
  DEPENDS namespaceB/moduleB1
}

# Invoked before each function call
# $1 is the name of the function to be called.
namesapceA_moduleA1_prepare() {
  var=123
  B1=namespaceB_moduleB1
}

# Real name of function to export
_namesapceA_moduleA1_hello() {
  var1='this is local variable'
  var2='this is not local variable'

  echo "hello $@"
}

_namesapceA_moduleA1_bye() {
  # call other module function with full module name
  namespaceB_moduleB1_bye "$@"

  # In this way you can use short aliases.
  ${B1}_bye "$@"
}
```

## References

### $SH_MODULE_DIR

Module base directories separated by `:`

### IMPORT

Use to import modules.

`Usage: IMPORT <namespace/module>[:<prefix>] [<funcname[:alias]>...]`

#### example

namespace/module exports three functions, foo(), bar() and baz().

`IMPORT namespace/module`

  * Imports all functions from module with default prefix.
  * namespace_module_foo(), namespace_module_bar(), namespace_module_baz() functions are defined.

`IMPORT namespace/module:`

 * Imports all functions from module without prefix.
 * foo(), bar(), baz() functions are defined.

`IMPORT namespace/module:sh`

  * Imports all functions from module with prefix.
  * sh_foo(), sh_bar(), sh_baz() functions are defined.

`IMPORT namespace/module foo`

  * Imports specified functions from module with default prefix.
  * namespace_module_foo() function is defined.

`IMPORT namespace/module: foo`

  * Imports specified functions from module without prefix.
  * foo() function is defined.

`IMPORT namespace/module:sh foo`

  * Imports specified functions from module with prefix.
  * sh_foo() function is defined.

`IMPORT namespace/sample:sh foo bar:my_bar baz:baz`

  * Imports specified functions from module with alias.
  * sh_foo(), my_bar(), namespace_baz() functions are defined.

### DEFAULT_LOCAL <variable-names>...

localize variable for all function.

### EXPORT

Use to export function in module initializer.

`Usage: EXPORT <funcname>[:<original>] [variable-names...]`

**The scope of specified variable-names and IFS will be local.**

### DEPENDS

Using other module function.

`Usage: DEPENDS <module>...`

## Release notes

### 0.1.0

  * First version.

### 0.2.0

  * Add DEPENDS function.
  * Add MODULE_SOURCE MODULE_NAME.
  * Fix several bugs.

### 0.2.1

  * Fix several bugs.

### 0.3.0

  * Change specification when prefix omitted.

### 0.4.0

  * Allow to place module under the directory.
  * Add DEFAULT_LOCAL function.
  * Add prepare callback.

### 0.5.0

  * EXPORT can specify the function name of the original.

### 0.5.1

  * Use shellspec for testing.
  * Fixed for unexpected modify path problem in zsh.
