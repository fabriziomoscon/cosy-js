'use strict'

{assert} = require './assert'
{isArr} = require './array'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Is the value a valid object?
#
# @param [mixed] value
# @return [Boolean]
isObj = (value) ->
  (value?) and
  (typeof value is 'object') and
  (not isArr value)

# Assert the value is a valid object
#
# @param [mixed] value
# @param [String] message
# @return [Object]
assertObj = (value, message = 'Invalid object') ->
  assert value, message, isObj

# Exports
module.exports = {
  isObj
  assertObj
}