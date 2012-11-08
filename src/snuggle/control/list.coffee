'use strict'

{collection, isCollection} = require '../../core/collection'
mutable = require '../../protocol/mutable'
{isRef} = require '../../core/reference'

instance = 0
# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

class List
  constructor: (@control, ref) ->
    throw new Error "First argument must be a reference" unless isRef ref
    instance += 1
    @instance = instance
    @collection = mutable.get ref
    unless isCollection @collection
      @collection = collection ref
      mutable.set ref, @collection

    @itemTemplate = @control.template 'item'

    @collection.onAppend @append
    @collection.onPrepend @prepend
    @collection.onRemove @remove
    @collection.onUpdate @update

    @renderAll()
    global.list = ref

  render: (index) =>
    item = @collection[index]
    @control.frame.item = item
    item.metadata.listElements ?= {}
    node = @control.render @itemTemplate, mutable.get item
    item.metadata.listElements[@instance] = node

  append: (index) =>
    @control.element.append @render index

  prepend: (index) =>
    @control.element.prepend @render index

  remove: (ref) =>
    element = ref.metadata.listElements[@instance]
    delete ref.metadata.listElements[@instance]
    element.remove()

  update: (index) =>

  renderAll: =>
    @control.element.html ''
    for item, index in @collection
      @append index

module.exports = {
  List
}
