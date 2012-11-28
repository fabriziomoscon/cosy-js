'use strict'

{ref, isRef} = require '../../core/reference'
{get, assoc} = require '../../protocol/map'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Add a list of properties to the current frame
#
# @param [HashMap] frame
# @param [Array] args
props = (frame, args...) ->
  refs = (get frame, 'refs') or {}
  for arg in args
    unless isRef refs[arg]
      refs[arg] = ref()
  frame['refs'] = refs
  frame

# Treat all unquoted symbols as strings
props.raw = /^[^"'].*$/

module.exports = {props}
