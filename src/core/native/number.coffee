'use strict'


# Is the value a valid number
# 
# @param [mixed] value
# @return [Boolean]
isNumber = (value) ->
  not (isNaN value) and typeof value is 'number'


# Exports
module.exports =

    isNum: isNumber

    # Assert the value is a valid number
    # 
    # @param [mixed] value
    # @param [String] message
    # @return [Number]
    assertNum: (value, message) ->
      throw (new Error message || 'Invalid number') unless (isNumber value)
      value
