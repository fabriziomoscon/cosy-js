'use strict'

map = require '../../protocol/map'
mutable = require '../../protocol/mutable'
{isRef, watchRef} = require '../../core/reference'
{evaluate, use} = require '../../core/evaluator'
{isFn} = require '../../core/native/function'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Parse ang args list replacing any refs with their content
#
# @param [Array] args
parseArgs = (args) ->
  newArgs = []
  for arg in args
    newArgs.push if (isRef arg) and (arg.passRef isnt true) then mutable.get arg else arg
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
      parts = /^([&])?(@|%)(.*)$/.exec arg
      args[index] = @props[parts[3]] if parts? and parts[2] is '@' and parts[3]?
      if parts? and parts[2] is '%' and parts[3]?
        args[index] = @global.getOrInitRef parts[3]

      args[index].passRef = true if parts? and parts[1] is '&'

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
