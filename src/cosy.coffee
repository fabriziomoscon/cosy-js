'use strict'

{hashMap} = require './core/hashMap'
evaluator = require './core/evaluator'
reader = require './core/reader'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Namespace
cosy = {}


# Start up cosy
#
# @param [domNode] startNode
# @return [hashMap] stackFrame
cosy.up = (startNode, imports) ->
  frame = evaluator.use evaluator.frame(), imports
  attributes = []
  attributes.push "[data-cosy-#{name}]" for own name, obj of imports
  selector = attributes.join ','
  ast = reader.read startNode, selector
  evaluator.apply ast, frame


# Important assertion
#
# @var [Boolean]
cosy.isAwesome = true


# Expose Snuggle
#
# @var [Object]
cosy.snuggle = require './snuggle'


# Exports
window.cosy = cosy if typeof window isnt 'undefined'
module.exports = cosy
