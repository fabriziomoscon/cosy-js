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
  (assertStr str).split /\s/

lookupRef = (frame, parts) ->
  name = list.first parts
  rest = list.rest parts
  ref = get frame, name
  if ref and rest
    lookupRef (use frame, ref), rest
  else
    ref

lookup = (frame, str) ->
  return str unless isStr str
  str = str.replace /^'(.*)'$/, '"$1"'
  ref = lookupRef frame, str.split /[.]/
  unless ref?
    if /^(true|false|[\d"[{])/i.exec str
      ref = JSON.parse str
    else
      location = ''
      if frame.__node?
        location = ' at ' + frame.__node[0].toString()
      throw new Error "Symbol #{str} not found" + location
  ref

evaluate = (cmd, frame) ->
  cmd = parse cmd if isStr cmd
  fn = lookup frame, list.first cmd
  assertFn fn, 'Unknown function ' + list.first cmd
  mapSymbol = (symbol) ->
    if fn.raw? and fn.raw.exec symbol
      symbol
    else
      lookup frame, symbol

  args = vec (map mapSymbol, (list.rest cmd))
  (console.log [(list.first cmd)].concat args) if (get frame, 'debug')
  fn frame, args...

proto = defProtocol
  apply: dispatch (type, frame) ->

extend proto, ((type) -> type is null),
  apply: (nil, frame) -> frame

extend proto, isStr,
  apply: (str, frame) ->
    evaluate str, frame

stringify = (_obj, prefix = '') ->
  cmds = []
  if isStr _obj
    cmds.push prefix + _obj
  else
    for own key, val of _obj
      cmds = cmds.concat (stringify val, prefix + key + ' ')
  cmds

extend proto, isCosy,
  apply: (_cosy, frame) ->
    cmds = stringify _cosy
    for cmd in cmds
      frame = proto.apply cmd, frame
    frame

extend proto, isTreeNode,
  apply: (node, frame) ->
    newFrame = (assoc frame, "__parent", (get frame, "__node"))
    newFrame = (assoc newFrame, "__node", (element node))
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
  evaluate
}
