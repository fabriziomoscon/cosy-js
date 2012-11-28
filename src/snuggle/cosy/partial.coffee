'use strict'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Define a template partial
#
# @param [HashMap] frame
# @param [String] name
# @return [HashMap]
partial = (frame, name) ->
  frame.__parent.partials ?= {}
  frame.__parent.partials[name] = frame.__node.html()
  frame

partial.raw = /^[^"'].*$/

module.exports = {partial}
