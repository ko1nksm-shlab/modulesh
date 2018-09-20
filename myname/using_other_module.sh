#!/bin/sh

myname_using_other_module() {
  DEFAULT_LOCAL M
  EXPORT hello
  DEPENDS myname/mymodule
}

myname_using_other_module_prepare() {
  M=myname_mymodule
}

_myname_using_other_module_hello() {
  ${M}_hello "$@"
}
