'use strict'

{assoc} = require '../protocol/map'
{evaluate} = require '../core/evaluator'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


handler = (frame, name) ->
  assoc frame, name, {}

handle = (frame, handler, signal, action...) ->
  handler[signal] = ->
    evaluate action, frame
  frame

trigger = (frame, handler, name) ->
  handler[name]()

module.exports = {
  handler
  handle
  trigger
}
