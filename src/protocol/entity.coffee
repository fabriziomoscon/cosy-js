'use strict'

{defProtocol, dispatch} = require '../core/protocol'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

module.exports = proto = defProtocol {
  update: dispatch (entity, newValue) ->
  remove: dispatch (entity) ->
  name: dispatch (entity) ->
  id: dispatch (entity) ->
}

