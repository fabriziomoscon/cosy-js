{defProtocol, dispatch, extend} = require '../core/protocol'
{ref, watchRef} = require '../core/reference'
{map, into} = require './list'
{set} = require './mutable'
{isFn, assertFn} = require '../core/native/function.coffee'
{assertStr} = require '../core/native/string.coffee'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Is the value a valid jQuery element
#
# @private
# @param [mixed] value
# @return [Boolean]
isJqueryElement = (value) ->
  (isFn value.data) and
  (isFn value.find) and
  (isFn value.val)


# Exports
module.exports = protocol = defProtocol {
  attr:
  attrs: dispatch (element) ->
  cosy: (element) -> (protocol.data element, 'cosy')
  css: dispatch (element, selector) ->
  data: dispatch (element, key) ->
  value: dispatch (element, value) ->
}


# Extend protocol for jQuery
extend protocol, isJqueryElement,

  # Get a reference to an element attribute
  #
  # @param [Element] element
  # @param [String] key
  # @return [Reference]
  attr: (element, key) ->
    watchRef (set ref(), (element.attr key)), (reference) ->
      element.attr key, (get reference)

  # Get a map of references to element attributes
  #
  # @param [Element] element
  # @return [Map]
  attrs: (element) ->
    map into,
      map (attr) ->
        ret = {}
        ret[attr.name] = protocol.attr element, attr.name
        ret
      , element.attributes

  # Get an element by selector
  #
  # @param [Element] element
  # @param [String] selector
  # @return [Element]
  css: (element, selector) ->
    element.find (assertStr selector, 'Invalid selector')

  # Get a reference to an element data attribute
  #
  # @param [Element] element
  # @param [String] key
  # @return [Reference]
  data: (element, key) ->
    watchRef (set ref(), (element.data key)), (reference) ->
      element.data key, (get reference)

  # Get a reference to an element value
  #
  # @param [Element] element
  # @param [String] key
  # @return [Reference]
  value: (element, key) ->
    watchRef (set ref(), (element.data key)), (reference) ->
      element.val key, (get reference)
