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

defProtocol = (spec) ->
  new Protocol spec

dispatch = (signature) ->
  fn = (args...) ->
    fn.validate args...
    fn.impl args...

  fn.impl = -> throw new Error "Function not implemented"
  fn.validate = (args...) ->
    throw (new Error "Invalid invocation") unless args.length is signature.length
  fn

addDispatch = (proto, pred, name, fn) ->
  throw (new Error 'Unknown function ' + name) unless proto[name]?

  chain = proto[name].impl
  proto[name].impl = (args...) ->
    if (pred args...) then (fn args...) else chain args...

  supports = proto.supports
  proto.supports = (args...) ->
    if (pred args...) then true else supports args...

extend = (proto, pred, spec) ->
  (addDispatch proto, pred, name, fn) for own name,fn of spec

supports = (proto, args...) ->
  proto.supports args...

module.exports = {
  defProtocol,
  extend,
  dispatch,
  supports
}
