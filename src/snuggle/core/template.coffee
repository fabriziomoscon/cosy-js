'use strict'

{render} = require 'cosy-js/src/protocol/template'
hogan = require 'cosy-js/src/template/hogan'
evaluator = require 'cosy-js/src/core/evaluator'
reader = require 'cosy-js/src/core/reader'
html = require './html'

template = (id) ->
  id ?= 'template'
  tmpl = (@element.find "script[data-id=#{id}]").eq 0
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

module.exports = {
  template,
  render: renderTemplate
}
