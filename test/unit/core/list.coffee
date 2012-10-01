'use strict'

{assert} = require 'chai'
{spy} = require 'sinon'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'list module', ->
  {map, reduce, filter, take, drop, vec} = require '../../../src/core/list'
  {first, rest} = require '../../../src/protocol/list'

  suite 'Array', ->
    list = mul2 = add = odd = null
    setup ->
      list = [1, 2, 3, 4 , 5]
      mul2 = (x) -> 2 * x
      add = (x, y) -> x + y
      odd = (x) -> if x % 2 isnt 0 then true else false

    test 'map', ->
      result = map mul2, list
      assert.equal 2, first result
      assert.equal 4, first rest result

    test 'reduce', ->
      assert.equal 15, reduce add, list

    test 'filter', ->
      result = filter odd, list
      assert.equal 1, first result
      assert.equal 3, first rest result

    test 'take', ->
      result = take 2, list
      assert.equal 1, first result
      assert.equal 2, first rest result
      assert.equal null, first rest rest result

    test 'drop', ->
      result = drop 3, list
      assert.equal 4, first result
      assert.equal 5, first rest result
      assert.equal null, first rest rest result

    test 'vec', ->
      assert.deepEqual [10, 8, 6, 4, 2], (vec (map mul2, list))

    suite 'combinations', ->
      test 'map reduce', ->
        assert.equal 30,
          reduce add, (map mul2, list)

      test 'filter reduce', ->
        assert.equal 9,
          reduce add, (filter odd, list)

      test 'filter map reduce', ->
        assert.equal 18,
          reduce add,
            map mul2,
              filter odd, list

      test 'take reduce', ->
        assert.equal 3,
          reduce add,
            take 2, list

      test 'srop reduce', ->
        assert.equal 12,
          reduce add,
            drop 2, list
