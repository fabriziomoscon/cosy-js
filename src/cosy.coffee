'use strict'

reader = require './core/reader'
evaluator = require './core/evaluator'
{hashMap} = require './core/hashMap'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Start up cosy
#
# @param [domNode] startNode
# @return [hashMap] stackFrame
up = (startNode, imports) ->
  frame = evaluator.use evaluator.frame(), imports
  attributes = []
  attributes.push "[data-cosy-#{name}]" for own name, obj of imports
  selector = attributes.join ','
  ast = reader.read startNode, selector
  evaluator.apply ast, frame

module.exports = {
  up
  isAwesome: true
  snuggle: require './snuggle'
}
