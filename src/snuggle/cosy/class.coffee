'use strict'

{isFn} = require '../../core/native/function'
{evaluate, use} = require '../../core/evaluator'

classControl = (constructor) ->
  (args...) ->
    if @isInitialising
      new constructor @, args...
    else if isFn @update
      @update args...

cosyClass = (frame, constructor, args...) ->
  control = classControl constructor
  evaluate (['control', control].concat args), frame

module.exports = cosyClass
