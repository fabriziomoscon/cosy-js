'use strict'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


attach = (frame, delay) ->
  frame.__node[0].frame = frame
  if delay is 'delay'
    frame.__delay = true
  frame

module.exports = attach
