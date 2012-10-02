'use strict'

reader = require './core/reader'
evaluator = require './core/evaluator'
{hashMap} = require './core/hashMap'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

deps = [
  require './lang/entity'
  require './lang/event'
]

# Start up cosy
#
# @param [domNode] startNode
# @return [hashMap] stackFrame
up = (startNode, reg) ->
  frame = hashMap {}
  frame = evaluator.use frame, dep for dep in deps
  frame = evaluator.use reg
  ast = reader.read startNode
  evaluator.apply ast, frame

module.exports = {
  up
  isAwesome: true
}
