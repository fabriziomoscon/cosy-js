'use strict'

{assert} = require 'chai'
{spy} = require 'sinon'
jQuery = require 'jquery'
{first} = require '../../../src/protocol/list'
{get, assoc} = require '../../../src/protocol/map'
{hashMap} = require '../../../src/core/hashMap'
reader = require '../../../src/core/reader'
dom = require '../../../src/dom/reader'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'Core Evaluator:', ->
  evaluator = require '../../../src/core/evaluator'
  frame = null
  suite 'Exports', ->
    setup ->
      frame = evaluator.frame()

    test 'use', ->
      obj =
        a: {}
        b: {}
      frame = evaluator.use frame, obj
      assert.strictEqual obj.a, (get frame, 'a')
      assert.strictEqual obj.b, (get frame, 'b')

    test 'apply string', ->
      obj =
        bar: "bar"
        def: (env, bar, val) ->
          assoc env, bar, val
      frame = evaluator.use frame, obj
      frame = evaluator.apply 'def bar 1', frame
      assert.strictEqual 1, (get frame, 'bar')

  suite 'Button', ->
    body = null
    setup ->
      html = '''
  <body>
    <div data-cosy="" data-cosy-entity="'foo'">
      <button data-cosy="" data-cosy-event="'click' remove foo">Remove</button>
    </div>
  </body>
  '''
      body = jQuery html
      ast = reader.read body
      frame = evaluator.frame()
      frame = evaluator.use frame,
        entity: (frame, name) ->
          assoc frame, name,
            name: name
            node: get frame, '__node'
        event: (frame, event, action...) ->
          node = get frame, '__node'
          node.on event, ->
            evaluator.evaluate action, frame
          frame
        remove: (frame, entity) ->
          entity.node.remove()
          frame

      frame = evaluator.apply ast, frame
      (body.find 'button').click()

    test 'Next frame is an object', ->
      assert.isObject frame

    test 'Body is empty', ->
      assert.match body[0].outerHTML, /^<body>\s*<\/body>\s*$/

  suite 'Dot syntax', ->
    body = null
    method = null
    setup ->
      html = '''
  <body>
    <div data-cosy="" data-cosy-test="a.b">
    </div>
  </body>
  '''
      method = spy()
      body = jQuery html
      ast = reader.read body
      frame = evaluator.frame()
      frame = evaluator.use frame,
        test: (frame, args...) ->
          method args...
          frame
        a:
          b: true

      frame = evaluator.apply ast, frame

    test 'Test methods called with test value', ->
      assert (method.withArgs true).calledOnce