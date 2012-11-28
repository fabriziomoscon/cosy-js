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
# @param [number] instance
parseArgs = (args, instance) ->
  newArgs = []
  for arg in args
    newArgs.push if (isRef arg) and (arg.metadata.controls[instance].passRef isnt true) then mutable.get arg else arg
  newArgs

# Entend a target object by adding all the properties of a src object to it
#
# @param [Object] tgtObj
# @param [Object] srcObj
# @param [HashMap] ctx
extend = (tgtObj, srcObj, ctx) ->
  for own name, value of srcObj
    do (name, value) ->
      if isFn value
        tgtObj[name] = (args...) -> value.apply ctx, args
      else
        tgtObj[name] = {}
        extend tgtObj[name], value, ctx

# Register a child control
#
# @param [HashMap] frame
# @param [Control] child
registerChild = (frame, child) ->
  return unless frame?
  if frame.__control?
    frame.__control.children.push child
  else if frame isnt frame.__parent
    registerChild frame.__parent, child

instance = 0

# Control Class
# @private
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

    instance += 1
    @instance = instance
    @destructors = []
    @children = []
    registerChild @frame, @
    @frame.__control = @

    apply = =>
      newArgs = parseArgs args, @instance
      fn.apply @, newArgs

    # Import name space
    ns = map.get @frame, 'namespace'
    extend @, ns, @

    @cosy = {
      control: (args...) ->
        evaluate (['control'].concat args), frame
      cmd: (element, cmd) ->
        newFrame = map.assoc frame, "__node", element
        evaluate cmd, newFrame
    }

    @props = map.get @frame, 'refs'
    @element = map.get @frame, '__node'

    for arg, index in args
      parts = /^([&])?(@|%)(.*)$/.exec arg
      if isRef args[index]
        args[index].metadata.controls ?= {}
        args[index].metadata.controls[@instance] ?= {}
        args[index].metadata.controls[@instance].passRef = true
      args[index] = @props[parts[3]] if parts? and parts[2] is '@' and parts[3]?
      if parts? and parts[2] is '%' and parts[3]?
        args[index] = @global.getOrInitRef parts[3]

      if isRef args[index]
        args[index].metadata.controls ?= {}
        args[index].metadata.controls[@instance] ?= {}
        args[index].metadata.controls[@instance].passRef = true if parts? and parts[1] is '&'
        @destructors.push do (controls = args[index].metadata.controls, index = @instance) ->
          ->
            delete controls[index] if controls[index]?


    # Watch any refs in the arg list
    for arg in args
      (@watchRef arg, apply) if isRef arg

    # Apply the control function
    @isInitialising = true
    apply()
    @isInitialising = false

  empty: =>
    while child = @children.pop()
      child.destroy()
    @element.html ''

  destroy: =>
    @empty()
    for fn in @destructors
      do fn
    @element.remove()

# Instantial a cosy control
#
# @param [HashMap] frame
# @param [Function] fn
# @param [Array] args
# @return [HashMap]
control = (frame, fn, args...) ->
  new Control frame, fn, args
  frame

# Treat all refs and globals as strings
control.raw = /^&?[%@].+$/

module.exports = {control}
