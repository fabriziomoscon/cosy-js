
# Dependencies
{assert} = require 'chai'


# Tests
suite 'native function:', ->
  {isFn, assertFn} = require '../../../../src/core/native/function'


  suite 'isFn:', ->
    test 'empty object is not a function', ->
      assert.isFalse (isFn {})

    test 'string is not a function', ->
      assert.isFalse (isFn 'foo')

    test 'function is a function', ->
      assert.isTrue (isFn ->)


  suite 'assertFn:', ->
    test 'call with empty object throws', ->
      assert.throws ->
        assertFn {}
      , /Invalid function/

    test 'call with string throws', ->
      assert.throws ->
        assertFn 'foo'
      , /Invalid function/

    test 'call with invalid function throws with given message', ->
      assert.throws ->
        assertFn {}, 'foo'
      , /foo/

    test 'call with function does not throw', ->
      assert.doesNotThrow ->
        assertFn ->
