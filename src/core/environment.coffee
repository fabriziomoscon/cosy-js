'use strict'

{isFn} = require './native/function.coffee'
{extend} = require './protocol'
mutable = require '../protocol/mutable'
{ref, getRef, setRef} = require './reference'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# @private
class Environment
  constructor: (console, domLib) ->
    @console = assertConsole console
    @domLib = assertDomLib domLib
    @ref = ref()


# Create a new environment
#
# @param [Console] console
# @param [jQuery] domLib
# @return [Environment]
env = (console, domLib) ->
  new Environment console, domLib

# Log data to the console
#
# @param [Environment] environment
# @param [mixed] data
log = (environment, data) ->
  (assertEnv environment).console.log data

# Is the value a valid environment
#
# @param [mixed] value
# @return [Boolean]
isEnv = (value) ->
  value instanceof Environment

# Assert the value is a valid environment
#
# @private
# @param [mixed] value
# @return [Environment]
assertEnv = (value) ->
  throw (new Error 'Invalid environment') unless (isEnv value)
  value

# Assert the value is a valid console
#
# @private
# @param [mixed] value
# @return [Console]
assertConsole = (value) ->
  throw (new Error 'Invalid console') unless (isFn value.log)
  value

# Assert the value is a valid console
#
# @private
# @param [mixed] value
# @return [DomLib]
assertDomLib = (value) ->
  if (isFn value.ajax) and
     (isFn value.append) and
     (isFn value.remove)
    return value
  throw (new Error 'Invalid DOM library')


# Exports
module.exports =
  env: env
  log: log
  isEnv: isEnv


# Extend mutable
extend mutable, isEnv,
  get: (environment) -> (getRef environment.ref)
  set: (environment, value) ->
    setRef environment.ref, value
    environment
