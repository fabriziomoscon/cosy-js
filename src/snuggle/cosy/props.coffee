'use strict'

{ref, isRef} = require '../../core/reference'
{get, assoc} = require '../../protocol/map'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


props = (frame, args...) ->
  refs = (get frame, 'refs') or {}
  for arg in args
    refs[arg] = ref() unless isRef refs[arg]
  assoc frame, 'refs', refs

module.exports = props
