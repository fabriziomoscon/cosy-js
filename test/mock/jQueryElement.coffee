'use strict'

{spy} = require 'sinon'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Existing jQuery properties/methods to make spies for
jQueryProperties = [
  'length', 'prevObject', 'context', 'selector'
]
jQueryMethods = [
  'add', 'addClass', 'after', 'andSelf', 'animate', 'append', 'appendTo', 'attr', 'before', 'bind', 'blur', 'change'
  'children', 'clearQueue', 'click', 'clone', 'closest', 'contents', 'context', 'css', 'data', 'dblclick', 'delay'
  'delegate', 'dequeue', 'detach', 'die', 'each', 'empty', 'end', 'eq', 'error', 'fadeIn', 'fadeOut', 'fadeTo'
  'fadeToggle', 'filter', 'find', 'first', 'focus', 'focusin', 'focusout', 'get', 'has', 'hasClass', 'height', 'hide'
  'hover', 'html', 'index', 'innerHeight', 'innerWidth', 'insertAfter', 'insertBefore', 'is', 'jquery', 'keydown'
  'keypress', 'keyup', 'last', 'length', 'live', 'load', 'load', 'map', 'mousedown', 'mouseenter', 'mouseleave'
  'mousemove', 'mouseout', 'mouseover', 'mouseup', 'next', 'nextAll', 'nextUntil', 'not', 'off', 'offset'
  'offsetParent', 'on', 'one', 'outerHeight', 'outerWidth', 'parent', 'parents', 'parentsUntil', 'position', 'prepend'
  'prependTo', 'prev', 'prevAll', 'prevUntil', 'promise', 'prop', 'pushStack', 'queue', 'ready', 'remove', 'removeAttr'
  'removeClass', 'removeData', 'removeProp', 'replaceAll', 'replaceWith', 'resize', 'scroll', 'scrollLeft', 'scrollTop'
  'select', 'serialize', 'serializeArray', 'show', 'siblings', 'size', 'slice', 'slideDown', 'slideToggle', 'slideUp'
  'stop', 'submit', 'text', 'toArray', 'toggle', 'toggle', 'toggleClass', 'trigger', 'triggerHandler', 'unbind'
  'undelegate', 'unload', 'unwrap', 'val', 'width', 'wrap', 'wrapAll', 'wrapInner'
]

# Create a mock jQuery element
mock = ->
  elem = {}
  elem[method] = spy() for method in jQueryMethods
  elem

# Exports
module.exports = {mock}
