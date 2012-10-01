'use strict'

{extend} = require './protocol'
mutable = require '../protocol/mutable'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Reference class
#
# @private
class Reference
  constructor: (value = null) ->
    @value = value
    @metadata =
      watches: []


# Create a new reference
#
# @param [mixed] value
# @return [Reference]
ref = (value) ->
  new Reference value

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

# Get the reference value
#
# @param [Reference] reference
# @return [mixed]
getRef = (reference) ->
  (assertRef reference).value

# Set the reference value
#
# @param [Reference] reference
# @return [Reference]
setRef = (reference, value) ->
  (assertRef reference).value = value
  notifyRef reference
  reference

# Watch a reference for changes
#
# @param [Reference] reference
# @param [Function] callbac
# @return [Reference]
watchRef = (reference, callback) ->
  (assertRef reference).metadata.watches.push callback
  reference

# Notify watchers
#
# @private
# @param [Reference] reference
# @return [Reference]
notifyRef = (reference) ->
  callback reference for callback in reference.metadata.watches
  reference


# Extend mutable
extend mutable, isRef,
  set: (reference, value) -> (setRef reference, value)
  get: (reference) -> (getRef reference)


# Exports
module.exports = {
  ref
  isRef
  getRef
  setRef
  watchRef
}
