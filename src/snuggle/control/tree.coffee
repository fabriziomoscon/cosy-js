'use strict'

{List} = require './list'
{isRef, ref: createRef} = require '../../core/reference'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

class Tree
  constructor: (@control, ref, template) ->
    list = new List @control, ref, template
    childElement = @control.role 'children'
    if childElement.length > 0
      ref.value.children = createRef()
      @control.cosy.cmd childElement, ['class', Tree, ref.value.children, list.itemTemplate ]

module.exports = {
  Tree
}
