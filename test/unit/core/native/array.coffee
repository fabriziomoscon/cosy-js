
# Dependencies
{assert} = require 'chai'


# Tests
suite 'native array:', ->
  {isArr, assertArr} = require '../../../../src/core/native/array'


  suite 'isArr:', ->

    test 'string is not an array', ->
      assert.isFalse (isArr 'foo')

    test 'empty object is not an array', ->
      assert.isFalse (isArr {})

    test 'NaN is not an array', ->
      assert.isFalse (isArr NaN)

    test 'argument list is not an array', ->
      assert.isFalse (isArr arguments)

    test 'array is an array', ->
      assert.isTrue (isArr [])


  suite 'assertArr:', ->

    test 'call with string throws', ->
      assert.throws ->
        assertArr 'foo'
      , /Invalid array/

    test 'call with empty object throws', ->
      assert.throws ->
        assertArr {}
      , /Invalid array/

    test 'call with NaN throws', ->
      assert.throws ->
        assertArr NaN
      , /Invalid array/

    test 'call with argument list throws', ->
      assert.throws ->
        assertArr arguments
      , /Invalid array/

    test 'call with invalid array throws with given message', ->
      assert.throws ->
        assertArr {}, 'foo'
      , /foo/

    test 'call with array does not throw', ->
      assert.doesNotThrow ->
        assertArr []
