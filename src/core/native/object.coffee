'use strict'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Dependencies
{isArr} = require './array'


# Is the value a valid object
#
# @param [mixed] value
# @return [Boolean]
isObject = (value) ->
  (value?) and
  (typeof value is 'object') and
  (not isArr value)


# Exports
module.exports =

    isObj: isObject

    # Assert the value is a valid object
    #
    # @param [mixed] value
    # @param [String] message
    # @return [Number]
    assertObj: (value, message = 'Invalid object') ->
      throw (new Error message) unless (isObject value)
      value
