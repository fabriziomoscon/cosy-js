{defProtocol, dispatch, extend} = require '../core/protocol'
{ref, watchRef} = require '../core/reference'
{hashMap} = require '../core/hashMap'
list = require './list'
{into} = require './list'
{map,} = require '../core/list'
mutable = require './mutable'
{isFn, assertFn} = require '../core/native/function.coffee'
{assertStr} = require '../core/native/string.coffee'

# cosy.js
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
  (value?) and
  (value.jquery?)
#  (isFn value.data) and
#  (isFn value.find) and
#  (isFn value.val)


# Exports
module.exports = protocol = defProtocol {
  attr: dispatch (element, key) ->
  attrs: dispatch (element) ->
  children: dispatch (element) ->
  cosy: (element) -> (protocol.data element, 'cosy')
  css: dispatch (element, selector) ->
  data: dispatch (element, key) ->
  text: dispatch (element) ->
  value: dispatch (element) ->
  parents: dispatch (element, selector) ->
  siblings: dispatch (element, selector) ->
  matches: dispatch (element, selector) ->
  listen: dispatch (element, event, fn) ->
  remove: dispatch (element) ->
}


# Extend mutable for jQuery
extend mutable, isJqueryElement,
  get: (element) -> element.html()
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
    result = {}
    result[attr.name] = attr.value for attr in element[0].attributes
    hashMap result

  # Get the children of an element
  #
  # @param [Element] element
  # @return [Array]
  children: (element) ->
    element.children()

  # Get an element by selector
  #
  # @param [Element] element
  # @param [String] selector
  # @return [Element]
  css: (element, selector) ->
    element.find (assertStr selector, 'Invalid selector')

  # Get a reference to the element data attribute
  #
  # @param [Element] element
  # @param [String] key
  # @return [Reference]
  data: (element, key) ->
    element.data (assertStr key)

  # Get a reference to an element text
  #
  # @param [Element] element
  # @return [Reference]
  text: (element) ->
    watchRef (mutable.set ref(), element.text()), (reference) ->
      element.text (mutable.get reference)

  # Get a reference to an element value
  #
  # @param [Element] element
  # @return [Reference]
  value: (element) ->
    watchRef (mutable.set ref(), element.val()), (reference) ->
      element.val (mutable.get reference)

  parents: (element, selector) ->
    element.parents (assertStr selector, 'Invalid selector')

  siblings: (element, selector) ->
    element.siblings (assertStr selector, 'Invalid selector')

  matches: (element, selector) ->
    element.is (assertStr selector, 'Invalid Selector')

  listen: (element, event, fn) ->
    element.on event, fn

  remove: (element) ->
    element.trigger "remove"
    element.remove()

# Extend protocol for jQuery
extend list, isJqueryElement,
  first: (jqList) ->
    if jqList.length
      jqList.eq 0
    else
      null
  rest: (jqList) ->
    if jqList.length
      jqList.slice 1
    else
      null
