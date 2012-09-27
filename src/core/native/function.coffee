'use strict'


# Is the value a valid function
# 
# @param [mixed] value
# @return [Boolean]
isFunction = (value) ->
  typeof value is 'function'


# Exports
module.exports =

    isFn: isFunction

    # Assert the value is a valid function
    # 
    # @param [mixed] value
    # @param [String] message
    # @return [Function]
    assertFn: (value, message) ->
      throw (new Error message || 'Invalid function') unless (isFunction value)
      value
