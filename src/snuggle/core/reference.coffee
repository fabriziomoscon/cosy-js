'use strict'

{set, get} = require '../../protocol/mutable'

copy = (src, tgt) ->
  set tgt, (get src)

notify = (ref) ->
  copy ref, ref

module.exports = {
  set
  get
  copy
  notify
}
