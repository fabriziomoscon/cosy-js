'use strict'

{render} = require '../../protocol/template'
hogan = require '../../template/hogan'
evaluator = require '../../core/evaluator'
reader = require '../../core/reader'
html = require './html'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


template = (id, element) ->
  id ?= 'template'
  element ?= @element
  tmpl = (element.find "script[data-id=#{id}]").eq 0
  if 'text/mustache' is tmpl.attr 'type'
    hogan.tmpl tmpl.html()
  else
    throw new Error "Unkown type for template #{id}"

renderTemplate = (tmpl, context) ->
  html = render tmpl, context
  tags = /^<.+>$/i.test html.replace(/[\r\n]/gm," ").trim()
  if tags
    element = $ html
  else
    element = @html.span {}, html

  ast = reader.read element, '[data-cosy-control],[data-cosy-ns],[data-cosy-props]'
  evaluator.apply ast, @frame
  element

renderRaw = (tmpl, context) ->
  render tmpl, context

module.exports = {
  template
  render: renderTemplate
  renderRaw
}
