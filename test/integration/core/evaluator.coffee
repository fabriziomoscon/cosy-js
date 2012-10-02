'use strict'

{assert} = require 'chai'
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

    test 'apply string flat call', ->
      obj =
        fn: (env) ->
          assoc env, 'foo', 'bar'
      frame = evaluator.use frame, obj
      frame = evaluator.apply 'fn', frame
      assert.strictEqual 'bar', (get frame, 'foo')

  suite 'Button', ->
    setup ->
      html = '''
  <body>
    <div data-cosy="" data-cosy-entity="foo">
      <button data-cosy="" data-cosy-event-click="remove foo">Remove</button>
    </div>
  </body>
  '''
      ast = reader.read jQuery html
      frame = evaluator.frame()

      frame = evaluator.apply ast, frame

    test 'Next environment is an object', ->
      assert.isObject frame
