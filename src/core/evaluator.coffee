'use strict'

{defProtocol, dispatch, extend, supports} = require './protocol'
list = require '../protocol/list'
{assoc, get} = require '../protocol/map'
{hashMap} = require './hashMap'
{isStr, assertStr} = require './native/string'
{doSeq, map, vec, filter} = require './list'
{assertFn} = require './native/function'
{isTreeNode, isTree, isCosy, node: root, children, cosy, element} = require './reader'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Tokenise a string
#
# @param [String] str
# @return [Array]
parse = (str) ->
  (assertStr str).split /\s/

# Lookup a symbol in the frame of reference given the part of the name
#
# @param [HashMap] frame
# @param [Array] parts
# @return [mixed]
lookupSymbol = (frame, parts) ->
  name = list.first parts
  rest = list.rest parts
  ref = get frame, name
  if ref and rest
    lookupSymbol (use frame, ref), rest
  else
    ref

# Lookup a symbol in the frame of reference given a string
#
# @param [HashMap] frame
# @param [String] str
# @return [mixed]
lookup = (frame, str) ->
  return str unless isStr str
  str = str.replace /^'(.*)'$/, '"$1"'
  ref = lookupSymbol frame, str.split /[.]/
  unless ref?
    if /^(true|false|[\d"[{])/i.exec str
      ref = JSON.parse str
    else
      location = ''
      if frame.__node?
        location = ' at ' + frame.__node[0].toString()
      throw new Error "Symbol #{str} not found" + location
  ref

# Evaluate a command in a frame of reference
#
# Commands can be strings or a tokenised array
#
# @param [mixed] cmd
# @param [HashMap] frame
# @return [mixed]
evaluate = (cmd, frame) ->
  cmd = parse cmd if isStr cmd
  fn = lookup frame, list.first cmd
  assertFn fn, 'Unknown function ' + list.first cmd
  mapSymbol = (symbol) ->
    if fn.raw? and fn.raw.exec symbol
      symbol
    else
      lookup frame, symbol

  filterSymbol = (symbol) ->
    symbol? and symbol isnt ''

  args = vec (map mapSymbol, (filter filterSymbol, (list.rest cmd)))
  (console.log [(list.first cmd)].concat args) if (get frame, 'debug')
  fn frame, args...

# Define the apply protocol
proto = defProtocol
  # Apply a type in a frame of reference
  #
  # @param [mixed] type
  # @param [HashMap] frame
  # @return [HashMap]
  apply: dispatch (type, frame) ->

# Applying null to a frame is a no-op
extend proto, ((type) -> type is null),
  apply: (nil, frame) -> frame

# Applying a string to a frame evaluates the string in the frame
extend proto, isStr,
  apply: (str, frame) ->
    evaluate str, frame

# Turn a cosy command into a string
# @todo check if this is still needed
#
# @param [Object] _obj
# @param [String] prefix
# @return [Array]
stringify = (_obj, prefix = '') ->
  cmds = []
  if isStr _obj
    cmds.push prefix + _obj
  else
    for own key, val of _obj
      cmds = cmds.concat (stringify val, prefix + key + ' ')
  cmds

# Applying a cosy command to a frame applies the command string to the frame
extend proto, isCosy,
  apply: (_cosy, frame) ->
    cmds = stringify _cosy
    for cmd in cmds
      newFrame = proto.apply cmd, frame
      if newFrame?
        frame = newFrame
    frame

# Applying a tree node to the frame applies the cosy command to the frame
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

# Applying a tree to a frame applies the node to the frame then applies the
# children to the resulting frame
extend proto, isTree,
  apply: (tree, frame) ->
    continueFn = ->
    frame = assoc frame, '__continue', (-> do continueFn)
    newFrame = proto.apply (root tree), frame
    newFrame["__parent"] = newFrame
    if newFrame?.__delay?
      continueFn = (nextFrame) ->
        delete newFrame.__delay
        delete frame.__continue
        proto.apply (children tree), newFrame
    else
      proto.apply (children tree), newFrame
    frame

# Add the properties of an object to a frame
#
# @param [HashMap] frame
# @param [Object] obj
# @return [HashMap]
use = (frame, obj) ->
  list.into frame, hashMap obj

# Creates an empty frame
#
# @return [HashMap]
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
