'use strict'

{ref: createRef} = require '../../core/reference'
map = require '../../protocol/map'
mutable = require '../../protocol/mutable'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


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
