'use strict'

{defProtocol, dispatch, extend, supports} = require './protocol'
list = require '../protocol/list'
{assoc, get} = require '../protocol/map'
{hashMap} = require './hashMap'
{isStr, assertStr} = require './native/string'
{doSeq, map, vec} = require './list'
{assertFn} = require './native/function'
{isTreeNode, isTree, isCosy, node: root, children, cosy, element} = require './reader'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

parse = (str) ->
  (assertStr str).split ' '

lookup = (frame, str) ->
  ref = get frame, str
  if ref?
    ref
  else
    JSON.parse str

evaluate = (str, frame) ->
  cmd = parse str
  fn = lookup frame, list.first cmd
  assertFn fn
  args = vec (map ((symbol) -> lookup frame, symbol), (list.rest cmd))
  fn frame, args...

proto = defProtocol
  apply: dispatch (type, frame) ->

extend proto, isStr,
  apply: (str, frame) ->
    evaluate str, frame

extend proto, isCosy,
  apply: (_cosy, frame) ->
    #evaluate _cosy, frame
    frame

extend proto, isTreeNode,
  apply: (node, frame) ->
    newFrame = (assoc frame, "__node", (element node))
    proto.apply (cosy node), newFrame

extend proto, ((type) -> supports list, type),
  apply: (list, frame) ->
    doSeq ((item) ->
      proto.apply item, frame
    ), list
    frame

extend proto, isTree,
  apply: (tree, frame) ->
    newFrame = proto.apply (root tree), frame
    proto.apply (children tree), newFrame
    frame

use = (frame, obj) ->
  list.into frame, hashMap obj

frame = ->
  hashMap {
    use
  }

module.exports = {
  apply: proto.apply
  use
  frame
}
