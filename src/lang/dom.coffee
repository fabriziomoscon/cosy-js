'use strict'

map = require '../protocol/map'
{first} = require '../protocol/list'
{parents, siblings, append, remove, children, value} = require '../protocol/element'
{get, set} = require '../protocol/mutable'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


swap = (frame) ->
  node = (map.get frame, "__node")
  parent = (first (parents node, "*"))
  from = (siblings node, "*")
  to = (get node)
  (set node, from)
  (append parent, to)
  frame

val = (frame) ->
  node = (map.get frame, "__node")
  value node

goto = (frame, location) ->

module.exports = {
  swap
  val
}
