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
suite 'snuggle core html:', ->
  html = require '../../../../src/snuggle/core/html'

  setup ->
    @ctx = snuggleContext.mock()
    @element = jQueryElement.mock()
    global.jQuery = global.$ = stub().returns @element

  teardown ->
    delete global.jQuery
    delete global.$

  test 'Exports functions for common HTML elements', ->
    assert.isFunction html.div, 'div'
    assert.isFunction html.h1, 'h1'
    assert.isFunction html.p, 'p'


  suite '<element> method:', ->

    setup ->
      @attrs = {bar: 'baz'}
      @result = html.div.call @ctx, @attrs, 'qux'

    test 'Creates and returns an element with the tag-name, attributes and content passed in', ->
      assert.isTrue global.jQuery.withArgs('<div />').calledOnce
      assert.isTrue @element.attr.withArgs(@attrs).calledOnce
      assert.isTrue @element.html.withArgs('qux').calledOnce
