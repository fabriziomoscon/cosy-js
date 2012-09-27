
# Dependencies
{assert} = require 'chai'


# Tests
suite 'native object:', ->
  {isObj, assertObj} = require '../../../../src/core/native/object'


  suite 'isObj:', ->

    test 'string is not an object', ->
      assert.isFalse (isObj 'foo')

    test 'array is not an object', ->
      assert.isFalse (isObj [])

    test 'null is not an object', ->
      assert.isFalse (isObj null)

    test 'plain object is an object', ->
      assert.isTrue (isObj {})

    test 'instance is an object', ->
      assert.isTrue (isObj (new Date))


  suite 'assertObj:', ->

    test 'call with string throws', ->
      assert.throws ->
        assertObj 'foo'
      , /Invalid object/

    test 'call with array throws', ->
      assert.throws ->
        assertObj []
      , /Invalid object/

    test 'call with null throws', ->
      assert.throws ->
        assertObj null
      , /Invalid object/

    test 'call with invalid object throws with given message', ->
      assert.throws ->
        assertObj [], 'foo'
      , /foo/

    test 'call with object does not throw', ->
      assert.doesNotThrow ->
        assertObj {}

    test 'call with instance does not throw', ->
      assert.doesNotThrow ->
        assertObj (new Date)
