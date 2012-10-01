'use strict'

{assert} = require 'chai'
jQuery = require 'jquery'
{first} = require '../../../src/protocol/list'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Tests
suite 'Core Reader:', ->
  reader = require '../../../src/core/reader'

  test 'Empty cosy directive', ->
    html = '<div data-cosy=""></div>'
    element = jQuery html

    ast = reader.read element

    assert.isObject (reader.cosy ast)

  test 'Empty object cosy directive', ->
    html = '<div data-cosy="{}"></div>'
    element = jQuery html

    ast = reader.read element

    assert.isObject (reader.cosy ast)

  test 'Cosy extended directives', ->
    html = '<div data-cosy-entity="foo"></div>'
    element = jQuery html

    ast = reader.read element

    assert.equal 'foo', (reader.cosy ast).entity

  test 'Multiple extended directives', ->
    html = '''<div data-cosy-entity="foo" data-cosy-event='{"click": "remove foo"}'></div>'''
    element = jQuery html

    ast = reader.read element
    assert.equal 'foo', ast.cosy.entity
    assert.equal 'remove foo', (reader.cosy ast).event.click

  test 'Second order extended directive', ->
    html = '''<div data-cosy-event-click='remove foo'></div>'''
    element = jQuery html

    ast = reader.read element
    assert.equal 'remove foo', (reader.cosy ast).event.click

  test 'Multiple Second order extended directives', ->
    html = '''<div data-cosy-event-click='remove foo' data-cosy-event-doubleclick='update foo'></div>'''
    element = jQuery html

    ast = reader.read element
    assert.equal 'remove foo', (reader.cosy ast).event.click
    assert.equal 'update foo', (reader.cosy ast).event.doubleclick

  test 'Nested directives', ->
    html = '''
<body>
  <div data-cosy="" data-cosy-entity="foo">
    <button data-cosy="" data-cosy-event-click="remove foo">Remove</button>
  </div>
</body>
'''
    ast = reader.read jQuery html
    assert.equal 'foo',
      (reader.cosy (first (reader.children ast))).entity

    assert.equal 'remove foo',
      (reader.cosy (first (reader.children (first (reader.children ast))))).event.click
