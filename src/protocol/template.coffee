'use strict'

{defProtocol, dispatch, extend} = require '../core/protocol'
{isStr} = require '../core/native/string'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Define protocol
module.exports = proto = defProtocol
  render: dispatch (template, context) ->

# Render string

extend proto, isStr,
  render: (template, context) ->
    template

# Render jQuery

isJqueryElement = (value) ->
  (value?) and
  (value.jquery?)

extend proto, isJqueryElement,
  render: (template, context) ->
    template
