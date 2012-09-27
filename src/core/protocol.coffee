'use strict'

# Cosy.js
# 
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

class Protocol
	constructor: (spec) ->
		@[name] = def for own name,def of spec

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
		return (fn args...) if (pred args...)
		chain args...

extend = (proto, pred, spec) ->
	(addDispatch proto, pred, name, fn) for own name,fn of spec

module.exports = {
	defProtocol,
	extend,
	dispatch
}
