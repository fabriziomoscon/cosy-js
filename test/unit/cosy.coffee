
# Dependencies
{assert} = require 'chai'


# Tests
suite 'cosy module', ->
  cosy = require '../../src/cosy'

  test 'should be an object', ->
    assert.isObject cosy

  test 'should be awesome', ->
    assert.isTrue cosy.isAwesome
