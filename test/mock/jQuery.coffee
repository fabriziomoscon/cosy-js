'use strict'

{spy} = require 'sinon'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

jQ = spy()
jQ.ajax = spy()
jQ.ready = spy()
# Exports
module.exports = jQ
