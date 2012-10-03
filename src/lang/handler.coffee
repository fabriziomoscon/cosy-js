'use strict'

{assoc} = require '../protocol/map'
{evaluate} = require '../core/evaluator'

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
