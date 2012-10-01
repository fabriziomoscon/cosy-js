'use strict'

{assert} = require 'chai'
jQuery = require 'jquery'
{first, rest} = require '../../../src/protocol/list'
{vec} = require '../../../src/core/list'
{get} = require '../../../src/protocol/mutable'
{matches} = require '../../../src/protocol/element'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Tests
suite 'Dom parsing:', ->
  reader = require '../../../src/dom/reader'

  test 'Does nothing on no match', ->
    element = jQuery '''
    <body><h1><span></span></h1></body>
'''

    result = reader.read element, 'div'
    assert.isNull first result.children

  test 'Depth 1 children', ->
    element = jQuery '''
    <body><h1><span></span></h1></body>
'''

    result = reader.read element, 'span'
    assert.isTrue matches (first result.children).node, 'span'

  test 'Depth 2 children', ->
    element = jQuery '''
    <body><h1><span><div><span>text</span></div></span></h1></body>
'''

    result = reader.read element, 'span'
    assert.isTrue matches (first (first result.children).children).node, 'span'
    assert.notEqual 'text', (get (first result.children).node)
    assert.equal 'text', (get (first (first result.children).children).node)

