'use strict'

map = require 'cosy-js/src/protocol/map'
mutable = require 'cosy-js/src/protocol/mutable'
{isRef, watchRef} = require 'cosy-js/src/core/reference'
{evaluate, use} = require 'cosy-js/src/core/evaluator'
{isFn} = require 'cosy-js/src/core/native/function'

# Parse ang args list replacing any refs with their content
#
# @param [Array] args
parseArgs = (args) ->
  newArgs = []
  for arg in args
    newArgs.push if isRef arg then mutable.get arg else arg
  newArgs

# Entend a target object by adding all the properties of a src object to it
#
# @param [Object] tgtObj
# @param [Object] srcObj
extend = (tgtObj, srcObj, ctx) ->
  for own name, value of srcObj
    do (name, value) ->
      if isFn value
        tgtObj[name] = (args...) -> value.apply ctx, args
      else
        tgtObj[name] = {}
        extend tgtObj[name], value, ctx

# Define what controls use as this
class Control
  # Construct a control adding watches and calling the control fn
  #
  # @param [HashMap] frame
  # @param [Function] fn
  # @param [Array] args
  constructor: (@frame, fn, args) ->
    unless isFn fn
      if @frame.__parentNS?
        return evaluate (['control', fn].concat args), (use @frame, @frame.__parentNS)
      else
        throw new Error fn + ' control not found'

    apply = =>
      newArgs = parseArgs args
      fn.apply @, newArgs

    # Import name space
    ns = map.get @frame, 'namespace'
    extend @, ns, @

    @cosy = {
      control: (args...) ->
        evaluate (['control'].concat args), frame
    }

    @props = map.get @frame, 'refs'
    @element = map.get @frame, '__node'

    for arg, index in args
      parts = /^(@|%)(.*)$/.exec arg
      args[index] = @props[parts[2]] if parts? and parts[1] is '@' and parts[2]?
      if parts? and parts[1] is '%' and parts[2]?
        args[index] = @global.getOrInitRef parts[2]

    # Watch any refs in the arg list
    for arg in args
      (watchRef arg, apply) if isRef arg

    # Apply the control function
    @isInitialising = true
    apply()
    @isInitialising = false

# Function to bind contol to this
control = (frame, fn, args...) ->
  new Control frame, fn, args
  frame

module.exports = control
