'use strict'

{collection, isCollection} = require '../../core/collection'
mutable = require '../../protocol/mutable'
{isRef, ref: createRef, notifyRef} = require '../../core/reference'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

instance = 0

class List
  constructor: (@control, ref, @itemTemplate) ->
    throw new Error "First argument must be a reference" unless isRef ref
    instance += 1
    @instance = instance
    @ref = ref
    coll = mutable.get ref

    loadCollection = (coll) =>
      unless isCollection coll
        @collection = collection ref
        mutable.set ref, @collection

    loadCollection collection

    items = @control.element.children '[data-item]'
    for item, index in items
      element = items.eq index
      itemData = (element.data 'item') or {}
      data = createRef itemData
      data.metadata.listElements ?= {}
      data.metadata.listElements[@instance] = element
      @collection.push data

    @itemTemplate ?= @control.template 'item'

    bindEvents = =>
      @collection.onAppend @append
      @collection.onPrepend @prepend
      @collection.onRemove @remove
      @collection.onUpdate @update

    unbindEvents = =>
      @collection.offAppend @append
      @collection.offPrepend @prepend
      @collection.offRemove @remove
      @collection.offUpdate @update

    bindEvents()
    @renderAll()

    @control.watchRef ref, =>
      coll = mutable.get ref
      if coll isnt @collection
        unbindEvents()
        loadCollection coll
        bindEvents()
        @control.empty()
        @renderAll()

  filter: (item) =>
    true

  render: (index) =>
    item = @collection[index]
    return unless @filter mutable.get item
    @control.frame.item = item
    item.metadata.listElements ?= {}
    node = @control.render @itemTemplate, mutable.get item
    oldNode = item.metadata.listElements[@instance]
    item.metadata.listElements[@instance] = node
    if oldNode?
      node.insertAfter oldNode
      for control in @control.children
        if oldNode is control.element
          control.destroy()
          oldNode = null
      if oldNode
        oldNode.remove()
    else
      @control.watchRef item, =>
        @render index
        notifyRef @ref
    node

  append: (index) =>
    node = @render index
    if node?
      @control.element.append node

  prepend: (index) =>
    node = @render index
    if node?
      @control.element.prepend node

  remove: (ref) =>
    return unless ref.metadata?.listElements?[@instance]?
    element = ref.metadata.listElements[@instance]
    delete ref.metadata.listElements[@instance]
    for control in @control.children
      if element is control.element
        control.destroy()
        element = null
    element.remove() if element?

  renderAll: =>
    @control.element.html ''
    for item, index in @collection
      if item.metadata?.listElements?[@instance]?
        @control.element.append item.metadata.listElements[@instance]
      else
        @append index

module.exports = {
  List
}
