'use strict'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Is the value a valid function?
#
# @param [mixed] value
# @return [Boolean]
isFn = (value) ->
  typeof value is 'function'

# Assert the value is a valid function
#
# @param [mixed] value
# @param [String] message
# @return [Function]
assertFn = (value, message = 'Invalid function') ->
  throw (new Error message) unless (isFn value)
  value


# Exports
module.exports = {
  isFn
  assertFn
}