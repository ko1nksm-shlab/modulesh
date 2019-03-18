Describe 'module.sh'
  load_module_sh() {
    SH_MODULE_DIR=.
    . "$SH_MODULE_DIR/module.sh"
  }
  Before "load_module_sh"
  exist_function() {
    if [ "${POSH_VERSION:-}" ]; then
      (unset -f "$1") 2>/dev/null
    else
      eval type "$1" >/dev/null 2>/dev/null
    fi
  }

  Describe 'Imports all functions from module with default prefix'
    Before "IMPORT myname/mymodule"

    Example 'call myname_mymodule_foo'
      When call myname_mymodule_foo "1 2" "3 4"
      The output should eq "ok: foo 2"
    End

    Example 'call myname_mymodule_foo'
      When call myname_mymodule_bar
      The output should eq "ok: bar 0"
    End

    Example 'call myname_mymodule_baz'
      When call myname_mymodule_baz
      The output should eq "ok: baz 0"
    End

    Describe 'Change variable'
      Before 'local_var="" global_var=""'
      Example 'call myname_mymodule_change_var'
        When call myname_mymodule_change_var
        The output should be present
        The variable local_var should eq ""
        The variable global_var should eq 1
      End
    End

    Describe 'myname_module_info'
      Example 'call myname_using_other_module_hello'
        When call myname_mymodule_module_info
        The output should eq "./myname/mymodule.sh myname_mymodule"
      End
    End

    Describe 'default_local'
      Before 'default_local_var=""'
      Example 'call myname_using_other_module_hello'
        When call myname_mymodule_default_local
        The output should be present
        The variable default_local_var should eq ""
      End
    End
  End

  Describe 'Imports all functions from module without prefix'
    Before "IMPORT myname/mymodule:"

    Example 'call foo'
      When call foo
      The output should eq "ok: foo 0"
    End

    Example 'call bar'
      When call bar
      The output should eq "ok: bar 0"
    End

    Example 'call baz'
      When call baz
      The output should eq "ok: baz 0"
    End
  End

  Describe 'Imports all functions from module with prefix'
    Before "IMPORT myname/mymodule:sh"

    Example 'call sh_foo'
      When call sh_foo
      The output should eq "ok: foo 0"
    End

    Example 'call sh_bar'
      When call sh_bar
      The output should eq "ok: bar 0"
    End

    Example 'call sh_baz'
      When call sh_baz
      The output should eq "ok: baz 0"
    End
  End

  Describe 'Imports specified functions from module with default prefix'
    Before "IMPORT myname/mymodule foo"

    Example 'call sh_foo'
      When call myname_mymodule_foo
      The output should eq "ok: foo 0"
    End

    Example 'mymodule_bar shoud not exist'
      When call exist_function mymodule_bar
      The status should be failure
    End

    Example 'mymodule_baz shoud not exist'
      When call exist_function mymodule_baz
      The status should be failure
    End
  End

  Describe 'Imports specified functions from module without prefix'
    Before "IMPORT myname/mymodule: foo"

    Example 'call foo'
      When call foo
      The output should eq "ok: foo 0"
    End

    Example 'mymodule_bar shoud not exist'
      When call exist_function mymodule_bar
      The status should be failure
    End

    Example 'mymodule_baz shoud not exist'
      When call exist_function mymodule_baz
      The status should be failure
    End

    Example 'bar shoud not exist'
      When call exist_function bar
      The status should be failure
    End

    Example 'baz shoud not exist'
      When call exist_function baz
      The status should be failure
    End
  End

  Describe 'Imports specified functions from module with prefix'
    Before "IMPORT myname/mymodule:sh foo"

    Example 'call sh_foo'
      When call sh_foo
      The output should eq "ok: foo 0"
    End

    Example 'call mymodule_bar'
      When call exist_function mymodule_bar
      The status should be failure
    End

    Example 'mymodule_baz shoud not exist'
      When call exist_function mymodule_baz
      The status should be failure
    End

    Example 'sh_bar shoud not exist'
      When call exist_function sh_bar
      The status should be failure
    End

    Example 'sh_baz shoud not exist'
      When call exist_function sh_baz
      The status should be failure
    End
  End

  Describe 'Imports specified functions from module with alias'
    Before "IMPORT myname/mymodule:sh foo bar:my_bar baz:baz"

    Example 'call sh_foo'
      When call sh_foo
      The output should eq "ok: foo 0"
    End

    Example 'mymodule_foo shoud not exist'
      When call exist_function mymodule_foo
      The status should be failure
    End

    Example 'call my_bar'
      When call my_bar
      The output should eq "ok: bar 0"
    End

    Example 'sh_bar shoud not exist'
      When call exist_function sh_bar
      The status should be failure
    End

    Example 'call baz'
      When call baz
      The output should eq "ok: baz 0"
    End

    Example 'sh_baz shoud not exist'
      When call exist_function sh_baz
      The status should be failure
    End
  End

  Describe 'Using other module'
    Before "IMPORT myname/using_other_module"

    Example 'call myname_using_other_module_hello'
      When call myname_using_other_module_hello "using_other_module"
      The output should eq "hello using_other_module"
    End
  End

  Describe 'myname_sub_foo'
    Before "IMPORT myname/sub/foo"

    Example 'call myname_using_other_module_hello'
      When call myname_sub_foo_hello
      The output should eq "sub foo"
    End
  End
End