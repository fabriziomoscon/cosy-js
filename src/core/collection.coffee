'use strict'

{isArr} = require './native/array'
{isFn} = require './native/function'
mutable = require '../protocol/mutable'
{vec, map} = require './list'
reference = require '../../core/reference'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

mapItem = (item) ->
  if reference.isRef item then item else reference.ref item

notify = (fnList, index) ->
  fn index for fn in fnList

class Collection extends Array
  append: []
  prepend: []
  removed: []
  update: []
  constructor: (@ref) ->
    super()
    newValues = (vec map mapItem, mutable.get @ref)
    Array.push @, newValues...

  push: (item) ->
    result = super mapItem item
    notify @append, @length - 1
    reference.notifyRef @ref
    result

  pop: ->
    result = super()
    if result?
      notify @removed, result
      reference.notifyRef @ref
      mutable.get result

  unshift: (item) ->
    result = super mapItem item
    notify @prepend, 0
    reference.notifyRef @ref
    result

  shift: ->
    result = super()
    if result?
      notify @removed, result
      reference.notifyRef @ref
      mutable.get result

  splice: (args...) ->
    result = super args...
    if result?
      for item in result
        notify @removed, item
      reference.notifyRef @ref
      mutable.get item for item in result

  indexOf: (item) ->
    return @indexOf mutable.get item if reference.isRef item
    for x, i in @
      if item is mutable.get x
        return i

  removeItem: (item) ->
    i = @indexOf item
    if i?
      ref = @[i]
      @[i..i] = []
      notify @removed, ref
      true

  removeFn: (fn) ->
    removed = false
    items = []
    for x in @
      if fn mutable.get x
        items.push x

    for x in items
      @removeItem x
      removed = true

    removed

  remove: (arg) ->
    if isFn arg
      removed = @removeFn arg
    else
      removed = @removeItem arg

    reference.notifyRef @ref if removed
    removed

  removeAll: ->
    @remove -> true

  onAppend: (fn) -> @append.push fn
  onPrepend: (fn) -> @prepend.push fn
  onRemove: (fn) -> @removed.push fn
  onUpdate: (fn) -> @update.push fn

collection = (ref) ->
  new Collection ref

isCollection = (type) ->
  type instanceof Collection

module.exports = {
  collection
  isCollection
}

