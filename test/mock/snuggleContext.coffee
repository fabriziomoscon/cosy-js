'use strict'

{spy} = require 'sinon'
jQueryElement = require './jQueryElement'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Create a mock snuggle context
mock = ->
  element: jQueryElement.mock()

# Exports
module.exports = {mock}
