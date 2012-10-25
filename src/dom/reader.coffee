'use strict'

{css, parents, matches} = require '../protocol/element'
{filter, map} = require '../core/list'
{first} = require '../protocol/list'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


isParent = (node, element, selector) ->
  return false unless element?
  cand = first parents element, selector
  if cand?
    # @todo remode need for [0]
    node[0] is cand[0]
  else
    true

# Starting at a node return a tree of all the element matching a selector
#
# @param [element] node
# @param [string] css selector
read = (node, selector) ->
  if node is null
    null
  else
    children = map ((element) -> read element, selector),
      filter ((element) -> isParent node, element, selector),
        css node, selector

    {node: node, children: children}

module.exports = {
  read
}
