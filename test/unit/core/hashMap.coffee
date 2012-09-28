'use strict'

{assert} = require 'chai'
{spy} = require 'sinon'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'hashMap module', ->
  {hashMap} = require '../../../src/core/hashMap'
  {assoc, dissoc, get, find, key, value} = require '../../../src/protocol/map'
  {first, rest, conj} = require '../../../src/protocol/list'

  suite 'Map protocol', ->
    map1 = null

    setup ->
      map1 = hashMap {a: 1, b: 2}

    test 'assoc', ->
      map2 = assoc map1, 'c', 3
      assert.deepEqual {a: 1, b: 2, c: 3}, map2

    test 'dissoc', ->
      map2 = dissoc map1, 'a'
      assert.deepEqual {b: 2}, map2

    test 'get', ->
      assert.equal 2, get map1, 'b'

    test 'find', ->
      assert.deepEqual ['a', 1], find map1, 'a'

    test 'key', ->
      assert.equal 'a', key (find map1, 'a')

    test 'value', ->
      assert.equal 2, value (find map1, 'b')

  suite 'List protocol', ->
    map = null
    setup ->
      map = hashMap {a: 1, b: 2, c: 3}

    test 'first', ->
      assert.equal 'a', (key (first map))

    test 'rest', ->
      assert.deepEqual {b: 2, c: 3}, (rest map)

    test 'conj map', ->
      assert.equal 7, (get (conj map, hashMap {x: 7}), 'x')

    test 'conj map item', ->
      assert.equal 7, (get (conj map, (first hashMap {x: 7})), 'x')
