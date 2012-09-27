'use strict'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Is the value a valid array?
#
# @param [mixed] value
# @return [Boolean]
isArr = Array.isArray or (value) ->
  (Object::toString.call value) is '[object Array]'

# Assert the value is a valid array
#
# @param [mixed] value
# @param [String] message
# @return [Array]
assertArr = (value, message = 'Invalid array') ->
  throw (new Error message) unless (isArr value)
  value


# Exports
module.exports = {
  isArr
  assertArr
}
