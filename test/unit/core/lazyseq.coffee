'use strict'

{assert} = require 'chai'
{spy} = require 'sinon'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'lazySeq module', ->
  {lazySeq} = require '../../../src/core/lazySeq'
  {cons} = require '../../../src/protocol/list'
  {take, vec} = require '../../../src/core/list'


  test 'numbers', ->
    numbers = (start) ->
      (cons start, lazySeq -> (numbers start+1))

    assert.deepEqual [4, 3, 2, 1], (vec (take 4, (numbers 1)))
