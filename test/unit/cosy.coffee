'use strict'

{assert} = require 'chai'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'cosy:', ->
  cosy = require '../../src/cosy'

  test 'should be an object', ->
    assert.isObject cosy

  test 'should be awesome', ->
    assert.isTrue cosy.isAwesome
