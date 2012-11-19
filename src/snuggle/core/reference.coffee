'use strict'

{set, get} = require '../../protocol/mutable'
{watchRef: coreWatchRef, unwatchRef} = require '../../core/reference'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


copy = (src, tgt) ->
  set tgt, (get src)

notify = (ref) ->
  copy ref, ref

watch = (watchedRef, watchFn) ->
  watchRef.call @, watchedRef, ->
    watchFn (get watchedRef)

watchRef = (watchedRef, watchFn) ->
  @destructors.push ->
    unwatchRef watchedRef, watchFn
  coreWatchRef watchedRef, watchFn

module.exports = {
  set
  get
  copy
  notify
  watch
  watchRef
}
