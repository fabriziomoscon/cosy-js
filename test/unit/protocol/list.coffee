'use strict'


# Dependencies
{assert} = require 'chai'
{spy} = require 'sinon'


# Tests
suite 'list:', ->
  {first, rest, cons} = require '../../../src/protocol/list'

  suite 'Array', ->
    myArray = null

    setup ->
      myArray = [1, 2, 3, 4]

    test 'First gets first element', ->
      assert.strictEqual 1, (first myArray)

    test 'Rest gets rest of list', ->
      assert.deepEqual [2, 3, 4], (rest myArray)