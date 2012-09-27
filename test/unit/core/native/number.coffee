
# Dependencies
{assert} = require 'chai'
{spy} = require 'sinon'


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
      assert.isFalse (isNum 'foo')

    test 'call with empty object throws', ->
      assert.isFalse (isNum {})

    test 'call with NaN throws', ->
      assert.isFalse (isNum NaN)

    test 'call with number does not throw', ->
      assert.isTrue (isNum 1)

    test 'call with decimal number does not throw', ->
      assert.isTrue (isNum 1.2)
