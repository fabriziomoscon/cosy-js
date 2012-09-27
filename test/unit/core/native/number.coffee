'use strict'

{assert} = require 'chai'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'native number:', ->
  {isNum, assertNum} = require '../../../../src/core/native/number'


  suite 'isNum:', ->

    test 'string is not a number', ->
      assert.isFalse (isNum 'foo')

    test 'empty object is not a number', ->
      assert.isFalse (isNum {})

    test 'NaN is not a number', ->
      assert.isFalse (isNum NaN)

    test 'number is a number', ->
      assert.isTrue (isNum 1)

    test 'decimal number is a number', ->
      assert.isTrue (isNum 1.2)


  suite 'assertNum:', ->

    test 'call with string throws', ->
      assert.throws ->
        assertNum 'foo'
      , /Invalid number/

    test 'call with empty object throws', ->
      assert.throws ->
        assertNum {}
      , /Invalid number/

    test 'call with NaN throws', ->
      assert.throws ->
        assertNum NaN
      , /Invalid number/

    test 'call with invalid number throws with given message', ->
      assert.throws ->
        assertNum {}, 'foo'
      , /foo/

    test 'call with number does not throw', ->
      assert.doesNotThrow ->
        assertNum 1

    test 'call with decimal number does not throw', ->
      assert.doesNotThrow ->
        assertNum 1.2

    test 'successful call returns the passed in number', ->
      val = 1
      assert.strictEqual (assertNum val), val
