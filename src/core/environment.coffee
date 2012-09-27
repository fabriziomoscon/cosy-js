'use strict'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Dependencies
{Reference} = require './reference.coffee'
{isFn} = require './native/function.coffee'


# @private
class Environment extends Reference
  constructor: (console, domLib) ->
    super
    @console = assertConsole console
    @domLib = assertDomLib domLib


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
  throw (new Error 'Invalid DOM Library')


# Exports
module.exports =

  # Create a new environment
  #
  # @param [Console] console
  # @param [jQuery] domLib
  # @return [Environment]
  env: (console, domLib) ->
    new Environment console, domLib

  # Log data to the console
  #
  # @param [Environment] environment
  # @param [mixed] data
  log: (environment, data) ->
    (assertEnv environment).console.log data

  isEnv: isEnv
