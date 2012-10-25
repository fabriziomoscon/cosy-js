'use strict'

{ref: createRef} = require '../../core/reference'
map = require '../../protocol/map'
mutable = require '../../protocol/mutable'

get = (name) ->
  globals = mutable.get (map.get @frame, 'global')
  ref = globals[name]
  if ref?
    mutable.get ref
  else
    throw new Error "Unknown ref"

getOrInitRef = (name) ->
  globals = mutable.get (map.get @frame, 'global')
  ref = globals[name]
  ref = createRef() unless ref?
  globals[name] = ref
  mutable.set (map.get @frame, 'global'), globals
  ref

set = (name, value) ->
  ref = getOrInitRef.call @, name
  mutable.set ref, value

module.exports = {
  getOrInitRef
  get
  set
}
