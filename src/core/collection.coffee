'use strict'

{isArr} = require './native/array'
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
  remove: []
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
    notify @remove, result
    reference.notifyRef @ref
    mutable.get result

  unshift: (item) ->
    result = super mapItem item
    notify @prepend, 0
    reference.notifyRef @ref
    result

  shift: ->
    result = super()
    notify @remove, result
    reference.notifyRef @ref
    mutable.get result

  onAppend: (fn) -> @append.push fn
  onPrepend: (fn) -> @prepend.push fn
  onRemove: (fn) -> @remove.push fn
  onUpdate: (fn) -> @update.push fn

collection = (ref) ->
  new Collection ref

isCollection = (type) ->
  type instanceof Collection

module.exports = {
  collection
  isCollection
}
