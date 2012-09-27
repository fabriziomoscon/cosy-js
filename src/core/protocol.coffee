'use strict'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


class Protocol
  constructor: (spec) ->
    @[name] = def for own name,def of spec
    @.supports = -> false

# Define a protocol 
#
# @param [Object] spec
# @return [Protocol]
defProtocol = (spec) ->
  new Protocol spec

# Create a function dispatcher
#
# @param [function] signature
# @return [function]
dispatch = (signature) ->
  fn = (args...) ->
    fn.validate args...
    fn.impl args...

  fn.impl = -> throw new Error "Function not implemented"
  fn.validate = (args...) ->
    throw (new Error "Invalid invocation") unless args.length is signature.length
  fn

# Add a function to a protocol dispatcher
#
# @private
# @param [Protocol] proto
# @param [function] pred
# @param [String] name
# @param [function] fn
addDispatch = (proto, pred, name, fn) ->
  throw (new Error 'Unknown function ' + name) unless proto[name]?

  chain = proto[name].impl
  proto[name].impl = (args...) ->
    if (pred args...) then (fn args...) else chain args...

  supports = proto.supports
  proto.supports = (args...) ->
    if (pred args...) then true else supports args...

# Extends a type to a protocol
#
# @param [Protocol] proto
# @param [function] pred
# @param [Object] spec
extend = (proto, pred, spec) ->
  (addDispatch proto, pred, name, fn) for own name,fn of spec

# Checks if a protocol is supported
#
# @param [Protocol] proto
# @param [mixed] args...
supports = (proto, args...) ->
  proto.supports args...

module.exports = {
  defProtocol
  extend
  dispatch
  supports
}
