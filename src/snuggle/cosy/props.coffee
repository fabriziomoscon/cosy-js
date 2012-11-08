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
    unless isRef refs[arg]
      refs[arg] = ref()
  assoc frame, 'refs', refs

props.raw = /^[^"'].*$/

module.exports = props
