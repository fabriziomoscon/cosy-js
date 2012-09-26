'use strict'

# Cosy.js
# 
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# @private
class Reference
  constructor: ->
    @value = null
    @metadata =
      watches: []


# Is the value a valid reference
# 
# @param [mixed] value
# @return [Boolean]
isRef = (value) ->
  value instanceof Reference

# Assert the value is a value reference
# 
# @private
# @param [Reference] value
# @return [Reference]
assertRef = (value) ->
  throw (new Error 'Invalid reference') unless (isRef value)
  value

# Notify watchers
# 
# @private
# @param [Reference] reference
# @return [Reference]
notify = (reference) ->
  callback reference for callback in reference.metadata.watches
  reference


# Exports
module.exports =

  # Create a new reference
  # 
  # @return [Reference]
  ref: ->
    new Reference

  # Get the reference value
  #
  # @param [Reference] reference 
  # @return [mixed]
  getRef: (reference) ->
    (assertRef reference).value

  # Set the reference value
  # 
  # @param [Reference] reference
  # @return [Reference]
  setRef: (reference, value) ->
    (assertRef reference).value = value
    notify reference
    reference

  # Watch a reference for changes
  # 
  # @param [Reference] reference
  # @param [Function] callbac
  # @return [Reference]
  watchRef: (reference, callback) ->
    (assertRef reference).metadata.watches.push callback
    reference

  isRef: isRef
