'use strict'

{defProtocol, dispatch, extend} = require '../core/protocol'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

module.exports = protocol = defProtocol
  key: dispatch (mapItem) ->
  value: dispatch (mapItem) ->
  assoc: dispatch (map, key, value) ->
  dissoc: dispatch (map, key) ->
  get: dispatch (map, key) ->
  find: dispatch (map, key) ->
