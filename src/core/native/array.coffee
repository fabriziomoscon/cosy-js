'use strict'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


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
