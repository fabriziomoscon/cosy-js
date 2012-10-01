'use strict'

{assert} = require 'chai'
{render} = require '../../../src/protocol/template'
{spy} = require 'sinon'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'hogan template:', ->
  {tmpl, isTmpl, renderTmpl} = require '../../../src/template/hogan'

  suite 'tmpl:', ->

    test 'tmpl with non-string templateString throws', ->
      assert.throws ->
        (tmpl {})
      , /Invalid template string/

    test 'tmpl with valid templateString does not throw', ->
      assert.doesNotThrow ->
        (tmpl 'foo')


  suite 'isTmpl:', ->

    test 'string is not a template', ->
      assert.isFalse (isTmpl 'foo')

    test 'empty object is not a template', ->
      assert.isFalse (isTmpl {})

    test 'tmpl returns a template', ->
      assert.isTrue (isTmpl (tmpl 'foo'))


  suite 'renderTmpl:', ->
    val = null

    setup ->
      val = (tmpl 'Hello {{thing}}!')

    test 'renderTmpl with an invalid template throws', ->
      assert.throws ->
        (renderTmpl {}, {})
      , /Invalid template/

    test 'renderTmpl with an invalid context throws', ->
      assert.throws ->
        (renderTmpl val, 'foo')
      , /Invalid context/

    test 'renderTmpl with valid arguments does not throw', ->
      assert.doesNotThrow ->
        (renderTmpl val, {})

    test 'renderTmpl uses Hogan with the template string and context, and returns the rendered string', ->
      assert.strictEqual (renderTmpl val, {thing: 'World'}), 'Hello World!'


  suite 'template protocols:', ->
    val = null

    setup ->
      val = (tmpl 'Hello {{thing}}!')

    test 'render on template returns the expected rendered string', ->
      assert.strictEqual (render val, {thing: 'World'}), 'Hello World!'
