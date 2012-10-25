'use strict'

{assert} = require 'chai'
{spy} = require 'sinon'
jQueryElement = require '../../mock/jQueryElement'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
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
