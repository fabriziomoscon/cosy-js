'use strict'

{assert} = require 'chai'
{spy} = require 'sinon'
snuggleContext = require '../../../mock/snuggleContext'
jQueryElement = require '../../../mock/jQueryElement'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'snuggle core state:', ->
  {state} = require '../../../../src/snuggle/core/state'

  setup ->
    @ctx = snuggleContext.mock()
    @element = jQueryElement.mock()


  suite 'initialise (with default state true):', ->

    setup ->
      @fooState = state.call @ctx, 'foo', true, @element

    test 'state classes/attributes are added/removed', ->
      assert.isTrue @element.addClass.withArgs('is-foo').calledOnce
      assert.isTrue @element.removeClass.withArgs('is-not-foo').calledOnce
      assert.isTrue @element.attr.withArgs('data-is-foo', true).calledOnce

    test 'state value is set to expected default', ->
      assert.isTrue @fooState.get()


  suite 'initialise (with default state false):', ->

    setup ->
      @fooState = state.call @ctx, 'foo', false, @element

    test 'state classes/attributes are added/removed', ->
      assert.isTrue @element.addClass.withArgs('is-not-foo').calledOnce
      assert.isTrue @element.removeClass.withArgs('is-foo').calledOnce
      assert.isTrue @element.removeAttr.withArgs('data-is-foo').calledOnce

    test 'state value is set to expected default', ->
      assert.isFalse @fooState.get()


  suite 'initialise with no element:', ->

    setup ->
      @fooState = state.call @ctx, 'foo', true

    test 'context element is used by default', ->
      assert.isTrue @ctx.element.addClass.withArgs('is-foo').calledOnce


  suite 'state instance:', ->

    setup ->
      @fooState = state.call @ctx, 'foo', true, @element

    test 'off method sets state', ->
      @fooState.off()
      assert.isFalse @fooState.get()

    test 'on method sets state', ->
      @fooState.off()
      @fooState.on()
      assert.isTrue @fooState.get()

    test 'toggle method toggles state', ->
      @fooState.toggle()
      assert.isFalse @fooState.get()
      @fooState.toggle()
      assert.isTrue @fooState.get()

    test 'on/off/toggle methods add/remove classes', ->
      @element.addClass.reset() # reset spy
      @fooState.on()
      @fooState.off()
      @fooState.toggle()
      assert.strictEqual @element.addClass.callCount, 3
