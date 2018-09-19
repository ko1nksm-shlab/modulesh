# module.sh

Tiny module system for POSIX compatible shell script.

Supported shell: `dash`, `bash`, `zsh`, `ksh`, `mksh`, `yash`, `posh`, `busybox (ash)`

## Using module

```shell
  SH_MODULE_DIR=<module base directory>
  . "$SH_MODULE_DIR/module.sh"

  IMPORT namespaceA/moduleA1:my
  my_hello "module"
```

example module directory

```
Module base directory ($SH_MODULE_DIR)
├ module.sh
│
├ namespaceA
│  ├ moduleA1.sh
│  └ moduleA2.sh
└ namespaceB
    ├ moduleB1.sh
    └ moduleB1.sh
```

## Create module

example module: `namesapceA/moduleA1.sh`

```shell
#!/bin/sh

# initializer: Invoked by module.sh to export functions
namesapceA_moduleA1() {
  # export hello function and localize var1
  EXPORT hello var1

  # Using other module
  DEPENDS namespaceB/moduleB1
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

  * Imports all functions from module with default prefix
  * module_foo(), module_bar(), module_baz() functions are defined.

`IMPORT namespace/module:`

 * Imports all functions from module without prefix
 * foo(), bar(), baz() functions are defined.

`IMPORT namespace/module:sh`

  * Imports all functions from module with prefix
  * sh_foo(), sh_bar(), sh_baz() functions are defined.

`IMPORT namespace/module foo`

  * Imports specified functions from module with default prefix
  * module_foo() function is defined.

`IMPORT namespace/module: foo`

  * Imports specified functions from module without prefix
  * foo() function is defined.

`IMPORT namespace/module:sh foo`

  * Imports specified functions from module with prefix
  * sh_foo() function is defined.

`IMPORT ko1nksm/sample:sh foo bar:my_bar baz:baz`

  * Imports specified functions from module with alias
  * sh_foo(), my_bar(), baz() functions are defined.

### EXPORT

Use to export function in module initializer.

`Usage: EXPORT <funcname> [variable-names...]`

**The scope of specified variable-names and IFS will be local.**

### DEPENDS

Using other module function.

`Usage: DEPENDS <module>...`

## Release notes

### 2018-09-18 0.1.0

  * First version

### 2018-09-19 0.2.0

  * Add DEPENDS function
  * Fix nested namespace
