'use strict'

{assertObj} = require '../core/native/object'
{assertStr} = require '../core/native/string'
{extend} = require '../core/protocol'
{compile} = require 'hogan'
template = require '../protocol/template'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# HoganTemplate class
#
# @param [String] templateString
# @private
class HoganTemplate
  constructor: (templateString) ->
    (assertStr templateString, 'Invalid template string')
    @template = (compile templateString)


# Create a new Hogan template
#
# @param [String] templateString
# @return [HoganTemplate]
tmpl = (templateString) ->
  new HoganTemplate templateString

# Is the value a valid Hogan template?
#
# @param [mixed] value
# @return [Boolean]
isTmpl = (value) ->
  value instanceof HoganTemplate

# Assert the value is a valid Hogan template
#
# @private
# @param [HoganTemplate] value
# @return [HoganTemplate]
assertTmpl = (value) ->
  throw (new Error 'Invalid template') unless (isTmpl value)
  value

# Render a template
#
# @param [HoganTemplate] template
# @param [Object] context
# @return [Boolean]
renderTmpl = (template, context) ->
  (assertObj context, 'Invalid context')
  (assertTmpl template).template.render context


# Extend template
extend template, isTmpl,
  render: (template, context) -> (renderTmpl template, context)


# Exports
module.exports = {
  tmpl
  isTmpl
  renderTmpl
}
