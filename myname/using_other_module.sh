#!/bin/sh

myname_using_other_module() {
  EXPORT hello
  DEPENDS myname/mymodule
}

_myname_using_other_module_hello() {
  myname_mymodule_hello "$@"
}
