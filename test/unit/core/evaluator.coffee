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
  suite 'Parsing:', ->
    frame = null

    setup ->
      frame = evaluator.frame()

    test 'Not found symbol', ->
      frame.test = spy()
      assert.throws ->
        evaluator.apply "test foo", frame
      , 'Evaluator throws'

      assert.isFalse frame.test.calledOnce, 'Function not called'

    test 'Found symbol', ->
      frame.test = spy()
      frame.foo = 'foo'

      evaluator.apply "test foo", frame
      assert frame.test.withArgs(frame, 'foo').calledOnce, 'Function is called'

    test 'Called with a number', ->
      frame.test = spy()
      evaluator.apply "test 1.2", frame
      assert frame.test.withArgs(frame, 1.2).calledOnce, 'Function is called'

    test 'Called with a boolean', ->
      frame.test = spy()
      evaluator.apply "test true false", frame
      assert frame.test.withArgs(frame, true, false).calledOnce, 'Function is called'

    test 'Called with a "string"', ->
      frame.test = spy()
      evaluator.apply 'test "string"', frame
      assert frame.test.withArgs(frame, "string").calledOnce, 'Function is called'

    test 'Called with a \'string\'', ->
      frame.test = spy()
      evaluator.apply 'test \'string\'', frame
      assert frame.test.withArgs(frame, "string").calledOnce, 'Function is called'

    test 'Called with an array', ->
      frame.test = spy()
      evaluator.apply 'test [1,2,3]', frame
      assert frame.test.withArgs(frame).calledOnce, 'Function is called'
      assert.deepEqual frame.test.args[0][1], [1,2,3]

    test 'Called with an object', ->
      frame.test = spy()
      evaluator.apply 'test {"a":[1,2,3]}', frame
      assert frame.test.withArgs(frame).calledOnce, 'Function is called'
      assert.deepEqual frame.test.args[0][1].a, [1,2,3]
