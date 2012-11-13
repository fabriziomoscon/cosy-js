'use strict'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


partial = (frame, name) ->
  frame.partials ?= {}
  frame.partials[name] = frame.__node.html()
  frame

partial.raw = /^[^"'].*$/

module.exports = {partial}
