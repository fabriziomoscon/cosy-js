'use strict'

# Dependencies
{assert} = require 'chai'
{spy} = require 'sinon'
element = require '../../mock/jQueryElement'


suite 'element protocol:', ->
  {cosy, data, value} = require '../../../src/protocol/element'

  suite 'cosy:', ->
    test 'call with empty object throws', ->
      assert.throws ->
        cosy {}

    test 'call with string throws', ->
      assert.throws ->
        cosy 'foo'

    ## adlawson need to write more tests. brace yourselves...
