'use strict'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Is the value a valid string?
#
# @param [mixed] value
# @return [Boolean]
isStr = (value) ->
  typeof value is 'string'

# Assert the value is a valid string
#
# @param [mixed] value
# @param [String] message
# @return [String]
assertStr = (value, message = 'Invalid string') ->
  throw (new Error message) unless (isStr value)
  value


# Exports
module.exports = {
  isStr
  assertStr
}