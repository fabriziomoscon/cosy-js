'use strict'

{isArr} = require './native/array'
{isFn} = require './native/function'
mutable = require '../protocol/mutable'
{vec, map} = require './list'
reference = require './reference'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Maps an item to a reference of the item if it isn't already
#
# @param [mixed] item
# @return [Reference]
mapItem = (item) ->
  if reference.isRef item then item else reference.ref item

# Given an array of functions, call each passing the index
#
# @param [Array] fnList
# @param [integer] index
notify = (fnList, index) ->
  fn? index for fn in fnList

# Collection class
class Collection extends Array
  constructor: (@ref) ->
    super()
    newValues = (vec map mapItem, mutable.get @ref)
    Array.prototype.push.apply @, newValues
    @append = []
    @prepend = []
    @removed = []
    @update = []

  # Push an item to the back of the collection
  #
  # @param [mixed] item
  push: (item) =>
    result = super mapItem item
    notify @append, @length - 1
    reference.notifyRef @ref
    result

  # Pop an item from the back of the collection
  #
  # @return [mixed]
  pop: =>
    result = super()
    if result?
      notify @removed, result
      reference.notifyRef @ref
      mutable.get result

  # Unshift an item to the front of the collection
  #
  # @param [mixed] item
  unshift: (item) ->
    result = super mapItem item
    notify @prepend, 0
    reference.notifyRef @ref
    result

  # Shift an item from the front of the collection
  #
  # @param [mixed] item
  shift: =>
    result = super()
    if result?
      notify @removed, result
      reference.notifyRef @ref
      mutable.get result

  # Splice the collection
  splice: (args...) =>
    result = super args...
    if result?
      for item in result
        notify @removed, item
      reference.notifyRef @ref
      mutable.get item for item in result

  # Return the index of an item
  #
  # @param [mixed] item
  # @return [number]
  indexOf: (item) =>
    return @indexOf mutable.get item if reference.isRef item
    for x, i in @
      if item is mutable.get x
        return i

  # Remove a specific item from the collection
  #
  # @param [mixed] item
  # @return [boolean]
  removeItem: (item) =>
    i = @indexOf item
    if i?
      ref = @[i]
      @[i..i] = []
      notify @removed, ref
      true

  # Remove items from the collection base on a predicate
  #
  # @param [Function] fn
  # @return [boolean]
  removeFn: (fn) =>
    removed = false
    items = []
    for x in @
      if fn mutable.get x
        items.push x

    for x in items
      @removeItem x
      removed = true

    removed

  # Remove items and notify of the change
  #
  # Can either be a specific item or a predicate
  #
  # @param [mixed] arg
  # @return [boolean]
  remove: (arg) =>
    if isFn arg
      removed = @removeFn arg
    else
      removed = @removeItem arg

    reference.notifyRef @ref if removed
    removed

  # Remove all items from the collection
  removeAll: =>
    if @length > 0
      @remove -> true
    else
      notify @update

  # Register an append callback
  #
  # @param [Function] fn
  onAppend: (fn) => @append.push fn

  # Register a prepend callback
  #
  # @param [Function] fn
  onPrepend: (fn) => @prepend.push fn

  # Register a remove callback
  #
  # @param [Function] fn
  onRemove: (fn) => @removed.push fn

  # Register an update callback
  #
  # @param [Function] fn
  onUpdate: (fn) => @update.push fn

# Create a collection
#
# @param [Reference] ref
# @return [Collection]
collection = (ref) ->
  new Collection ref

# Checks for a collection
#
# @param [mixed] type
# @return boolean
isCollection = (type) ->
  type instanceof Collection

module.exports = {
  collection
  isCollection
}
