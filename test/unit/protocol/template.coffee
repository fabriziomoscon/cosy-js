'use strict'

{assert} = require 'chai'
{spy} = require 'sinon'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'list:', ->
  {render} = require '../../../src/protocol/template'

  suite 'String', ->
    str = null

    setup ->
      str = "A temnplate"

    test 'Rendering a string returns the string', ->
      assert.strictEqual str, render str, {}
