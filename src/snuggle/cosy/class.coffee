'use strict'

{isFn} = require 'cosy-js/src/core/native/function'
{evaluate, use} = require 'cosy-js/src/core/evaluator'

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
