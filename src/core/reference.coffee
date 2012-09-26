
# @private
class Reference
  constructor: ->
    @value = null
    @metadata = {}


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
    reference

  isRef: isRef
