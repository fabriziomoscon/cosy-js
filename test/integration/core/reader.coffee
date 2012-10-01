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
suite 'Core Reader:', ->
  reader = require '../../../src/core/reader'

  test 'Empty cosy directive', ->
    html = '<div data-cosy=""></div>'
    element = jQuery html

    ast = reader.read element

    assert.isObject ast.cosy

  test 'Empty object cosy directive', ->
    html = '<div data-cosy="{}"></div>'
    element = jQuery html

    ast = reader.read element

    assert.isObject ast.cosy

  test 'Cosy extended directives', ->
    html = '<div data-cosy-entity="foo"></div>'
    element = jQuery html

    ast = reader.read element

    assert.equal 'foo', ast.cosy.entity

  test 'Multiple extended directives', ->
    html = '''<div data-cosy-entity="foo" data-cosy-event='{"click": "remove foo"}'></div>'''
    element = jQuery html

    ast = reader.read element
    assert.equal 'foo', ast.cosy.entity
    assert.equal 'remove foo', ast.cosy.event.click

  test 'Second order extended directive', ->
    html = '''<div data-cosy-event-click='remove foo'></div>'''
    element = jQuery html

    ast = reader.read element
    assert.equal 'remove foo', ast.cosy.event.click

  test 'Multiple Second order extended directives', ->
    html = '''<div data-cosy-event-click='remove foo' data-cosy-event-doubleclick='update foo'></div>'''
    element = jQuery html

    ast = reader.read element
    assert.equal 'remove foo', ast.cosy.event.click
    assert.equal 'update foo', ast.cosy.event.doubleclick
