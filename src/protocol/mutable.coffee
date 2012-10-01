'use strict'

{defProtocol, dispatch} = require '../core/protocol'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Define protocol
module.exports = defProtocol
  # Mutably set the value of a reference and return the refernce
  #
  # @param [Reference] variable
  # @param [mixed] value
  # @return [Refernce]
  set: dispatch (variable, value) ->



  # Get the current value of a reference
  #
  # @param [Reference] variable
  # @return [mixed]
  get: dispatch (variable) ->
