'use strict'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Assert the value passes the predicate
#
# @param [mixed] value
# @param [String] message
# @param [Function] predicate
# @return [mixed]
assert = (value, message, predicate) ->
  throw (new Error message) unless (predicate value)
  value

module.exports = {
  assert
}
