{defProtocol, dispatch} = require '../core/protocol'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

module.exports = defProtocol {
  set: dispatch (variable, value) ->
  get: dispatch (variable) ->
}
