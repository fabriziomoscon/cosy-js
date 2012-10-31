'use strict'

{assert} = require 'chai'
{spy, stub} = require 'sinon'
snuggleContext = require '../../../mock/snuggleContext'
jQueryElement = require '../../../mock/jQueryElement'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'snuggle core query:', ->
  query = require '../../../../src/snuggle/core/query'

  setup ->
    @ctx = snuggleContext.mock()
    @element = jQueryElement.mock()


  suite 'container method:', ->

    setup ->
      @containerElement = jQueryElement.mock()
      @element.closest = stub().returns @containerElement

    test 'looks for `data-container` in element parents and returns result', ->
      result = query.container.call @ctx, 'foo', @element
      assert.isTrue @element.closest.withArgs('[data-container=foo]').calledOnce
      assert.strictEqual result, @containerElement

    test 'uses context element when called with no element', ->
      query.container.call @ctx, 'foo'
      assert.isTrue @ctx.element.closest.withArgs('[data-container=foo]').calledOnce


  suite 'roles method:', ->

    setup ->
      @roleElement = jQueryElement.mock()
      @element.find = @ctx.element.find = stub().returns @roleElement

    test 'looks for `data-role` in element children and returns result', ->
      result = query.roles.call @ctx, 'foo', @element
      assert.isTrue @element.find.withArgs('[data-role=foo]').calledOnce
      assert.strictEqual result, @roleElement

    test 'uses context element when called with no element', ->
      query.roles.call @ctx, 'foo'
      assert.isTrue @ctx.element.find.withArgs('[data-role=foo]').calledOnce


  suite 'role method:', ->

    setup ->
      @roleElement = jQueryElement.mock()
      eq = stub().withArgs(0).returns @roleElement
      find = stub().returns {eq}
      @element.find = @ctx.element.find = find

    test 'looks for single `data-role` in element children and returns result', ->
      result = query.role.call @ctx, 'foo', @element
      assert.isTrue @element.find.withArgs('[data-role=foo]').calledOnce
      assert.strictEqual result, @roleElement

    test 'uses context element when called with no element', ->
      query.role.call @ctx, 'foo'
      assert.isTrue @ctx.element.find.withArgs('[data-role=foo]').calledOnce


  suite 'query method:', ->

    setup ->
      @queryElement = jQueryElement.mock()
      global.jQuery = global.$ = stub().returns @queryElement

    teardown ->
      delete global.jQuery
      delete global.$

    test 'performs a find in the document context', ->
      result = query.query.call @ctx, 'foo'
      assert.isTrue global.jQuery.withArgs('foo').calledOnce
      assert.strictEqual result, @queryElement


  suite 'onEvent method:', ->

    setup ->
      @handler = spy()

    test 'binds an event to the context element when called with no delegate', ->
      query.onEvent.call @ctx, 'click', @handler
      assert.isTrue @ctx.element.on.withArgs('click').calledOnce

    test 'binds a delegated event (with role element selector) to the context element when called with a delegate', ->
      query.onEvent.call @ctx, 'foo', 'click', @handler
      assert.isTrue @ctx.element.on.withArgs('click', '[data-role=foo]').calledOnce

    test 'passes a wrapped handler into the jquery event binding', ->
      query.onEvent.call @ctx, 'click', @handler
      assert.isFunction @ctx.element.on.firstCall.args[1]
      assert.notStrictEqual @ctx.element.on.firstCall.args[1], @handler


  suite 'on method:', ->

    setup ->
      @log = global.console.log
      global.console.log = spy()
      @handler = spy()

    teardown ->
      global.console.log = @log

    test 'logs a depreciated notice', ->
      query.on.call @ctx, 'click', @handler
      assert.isTrue global.console.log.withArgs('`on` is depreciated, please use `onEvent`').calledOnce

    test 'binds an event to the context element when called with no delegate', ->
      query.on.call @ctx, 'click', @handler
      assert.isTrue @ctx.element.on.withArgs('click').calledOnce

    test 'binds a delegated event (with role element selector) to the context element when called with a delegate', ->
      query.on.call @ctx, 'foo', 'click', @handler
      assert.isTrue @ctx.element.on.withArgs('click', '[data-role=foo]').calledOnce

    test 'passes a wrapped handler into the jquery event binding', ->
      query.on.call @ctx, 'click', @handler
      assert.isFunction @ctx.element.on.firstCall.args[1]
      assert.notStrictEqual @ctx.element.on.firstCall.args[1], @handler