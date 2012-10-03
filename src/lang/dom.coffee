'use strict'

map = require '../protocol/map'
{first} = require '../protocol/list'
{parents, siblings, append, remove, children} = require '../protocol/element'
{get, set} = require '../protocol/mutable'

swap = (frame) ->
  node = (map.get frame, "__node")
  parent = (first (parents node, "*"))
  from = (siblings node, "*")
  to = (get node)
  (set node, from)
  (append parent, to)
  frame

module.exports = {
  swap
}
