'use strict'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Dependencies
{defProtocol, dispatch} = require '../core/protocol'


# Define protocol
module.exports = defProtocol
  render: dispatch (template, context) ->
