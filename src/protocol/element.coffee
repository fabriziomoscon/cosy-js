{defProtocol, dispatch, extend} = require '../core/protocol'
{ref, watchRef} = require '../core/reference'
{map, into} = require './list'
mutable = require './mutable'
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
  attr: dispatch (element, key) ->
  attrs: dispatch (element) ->
  cosy: (element) -> (protocol.data element, 'cosy')
  css: dispatch (element, selector) ->
  data: (element, key) -> (protocol.attr element, 'data-' + (assertStr key))
  value: dispatch (element) ->
}


# Extend mutable for jQuery
extend mutable, isJqueryElement,
  get: (element) -> element.html
  set: (element, value) -> element.html value


# Extend protocol for jQuery
extend protocol, isJqueryElement,

  # Get a reference to an element attribute
  #
  # @param [Element] element
  # @param [String] key
  # @return [Reference]
  attr: (element, key) ->
    watchRef (mutable.set ref(), (element.attr (assertStr key))), (reference) ->
      element.attr key, (mutable.get reference)

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

  # Get a reference to an element value
  #
  # @param [Element] element
  # @return [Reference]
  value: (element) ->
    watchRef (mutable.set ref(), element.val), (reference) ->
      element.val (mutable.get reference)
