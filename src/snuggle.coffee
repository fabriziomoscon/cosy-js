'use strict'

{ref} = require './core/reference'
{hashMap} = require './core/hashMap'
{assoc} = require './protocol/map'
evaluator = require './core/evaluator'
reader = require './core/reader'
core = require './snuggle/core'
cosy = require './snuggle/cosy'
control = require './snuggle/control'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Namespace
snuggle = {}


# Snuggle up
#
# @param [domNode] startNode
# @param [Object] controls
# @param [Object] lib
# @param [Boolean] debug
snuggle.up = (startNode, controls, lib, debug = false) ->
  frame = evaluator.frame()
  for own name, value of lib
    if core[name]?
      throw new Error "Cannot overwrite #{name} in core"
    core[name] = value

  frame = assoc frame, 'namespace', core
  frame = assoc frame, 'cosy', control
  frame = evaluator.use frame, cosy
  frame = evaluator.use frame, controls
  frame = assoc frame, 'global', ref {}
  frame = assoc frame, 'debug', debug

  snuggle.up.to startNode, frame


# Snuggle up with a given frame
#
# @param [domNode] startNode
# @param [hashMap] frame
snuggle.up.to = (startNode, frame) ->
  attributes = []
  attributes.push "[data-cosy-#{name}]" for own name, obj of cosy
  selector = attributes.join ','
  frame.__selector = selector
  startNode.each (index, element) ->
    ast = reader.read $(element), selector
    evaluator.apply ast, frame


# Exports
window.snuggle = snuggle if typeof window isnt 'undefined'
module.exports = snuggle
