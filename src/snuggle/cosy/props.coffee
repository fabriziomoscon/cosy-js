'use strict'

{ref} = require '../../core/reference'
{get, assoc} = require '../../protocol/map'

props = (frame, args...) ->
  refs = (get frame, 'refs') or {}
  for arg in args
    refs[arg] = ref()
  assoc frame, 'refs', refs

module.exports = props
