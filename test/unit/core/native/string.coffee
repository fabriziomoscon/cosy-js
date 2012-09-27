'use strict'

{assert} = require 'chai'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'native string:', ->
  {isStr, assertStr} = require '../../../../src/core/native/string'


  suite 'isStr:', ->

    test 'number is not a string', ->
      assert.isFalse (isStr 1)

    test 'empty object is not a string', ->
      assert.isFalse (isStr {})

    test 'string is a string', ->
      assert.isTrue (isStr 'foo')


  suite 'assertStr:', ->

    test 'call with number throws', ->
      assert.throws ->
        assertStr 1
      , /Invalid string/

    test 'call with empty object throws', ->
      assert.throws ->
        assertStr {}
      , /Invalid string/

    test 'call with invalid string throws with given message', ->
      assert.throws ->
        assertStr 1, 'foo'
      , /foo/

    test 'call with string does not throw', ->
      assert.doesNotThrow ->
        assertStr 'foo'

    test 'successful call returns the passed in string', ->
      val = 'foo'
      assert.strictEqual (assertStr val), val
