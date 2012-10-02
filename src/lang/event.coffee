'use strict'

element = require '../protocol/element'
{get} = require '../protocol/map'
{evaluate} = require '../core/evaluator'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


module.exports =
  event: (frame, event, action...) ->
    node = get frame, '__node'
    element.listen node, event, (evt) ->
      evt.preventDefault()
      evaluate action, frame
    frame
