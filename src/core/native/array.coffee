'use strict'


# Is the value a valid array
#
# @param [mixed] value
# @return [Boolean]
isArray = Array.isArray or (value) ->
  (Object::toString.call value) is '[object Array]'


# Exports
module.exports =

    isArr: isArray

    # Assert the value is a valid array
    #
    # @param [mixed] value
    # @param [String] message
    # @return [Number]
    assertArr: (value, message = 'Invalid array') ->
      throw (new Error message) unless (isArray value)
      value
