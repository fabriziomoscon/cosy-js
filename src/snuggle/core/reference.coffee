'use strict'

{set, get} = require '../../protocol/mutable'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


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
