'use strict'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Call a function
#
# @param [HashMap] frame
# @param [Function] fn
# @param [Array] args
# @return [HashMap]
call = (frame, fn, args...) ->
  fn frame.__node, args...
  frame

module.exports = {call}
