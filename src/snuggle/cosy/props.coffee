'use strict'

{ref} = require 'cosy-js/src/core/reference'
{get, assoc} = require 'cosy-js/src/protocol/map'

props = (frame, args...) ->
  refs = (get frame, 'refs') or {}
  for arg in args
    refs[arg] = ref()
  assoc frame, 'refs', refs

module.exports = props
