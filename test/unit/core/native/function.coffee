
# Dependencies
{assert} = require 'chai'
{spy} = require 'sinon'


# Tests
suite 'native function:', ->
  fn = require '../../../../src/core/native/function'

  suite 'function:', ->
    test 'isFn returns false with invalid function', ->
      assert.isFalse (fn.isFn {})

    test 'isFn returns true with a valid function', ->
      assert.isTrue (fn.isFn spy)

    test 'assertFn throws with invalid function', ->
      assert.throws ->
        fn.assertFn {}
      , /Invalid function/

    test 'assertFn does not throw with a valid function', ->
      assert.doesNotThrow ->
        fn.assertFn spy()
