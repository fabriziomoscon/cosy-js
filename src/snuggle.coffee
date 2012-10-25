'use strict'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


evaluator = require './core/evaluator'
reader = require './core/reader'
{ref} = require './core/reference'
{hashMap} = require './core/hashMap'
{assoc} = require './protocol/map'

core = require './snuggle/core'

cosy = require './snuggle/cosy'

up = (startNode, controls, lib, debug = false) ->
  frame = hashMap {}
  for own name, value of lib
    if core[name]?
      throw new Error "Cannot overwrite #{name} in core"
    core[name] = value

  frame = assoc frame, 'namespace', core
  frame = evaluator.use frame, cosy
  frame = evaluator.use frame, controls
  frame = assoc frame, 'global', ref {}
  frame = assoc frame, 'debug', debug

  up.to startNode, frame

up.to = (startNode, frame) ->
  attributes = []
  attributes.push "[data-cosy-#{name}]" for own name, obj of cosy
  selector = attributes.join ','
  startNode.each (index, element) ->
    ast = reader.read $(element), selector
    evaluator.apply ast, frame

module.exports = {
  up
}
