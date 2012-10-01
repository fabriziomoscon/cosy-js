'use strict'

{assert} = require 'chai'
{spy} = require 'sinon'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'list:', ->
  {first, second, rest, conj, cons} = require '../../../src/protocol/list'

  suite 'Array', ->
    myArray = null

    setup ->
      myArray = [1, 2, 3, 4]

    test 'First gets first element', ->
      assert.strictEqual 1, (first myArray)

    test 'Second gets first element', ->
      assert.strictEqual 2, (second myArray)

    test 'Rest gets rest of list', ->
      assert.deepEqual [2, 3, 4], (rest myArray)

    test 'Conj appends an element', ->
      assert.deepEqual [1, 2, 3, 4, 5], (conj myArray, 5)

    test 'Cons appends an element', ->
      assert.deepEqual [1, 2, 3, 4, 5], (cons 5, myArray)
