'use strict'

{children} = require 'cosy-js/src/protocol/element'
{filter, map, reduce} = require 'cosy-js/src/core/list'
{into} = require 'cosy-js/src/protocol/list'
{hashMap} = require 'cosy-js/src/core/hashMap'

formTags = [
  "input"
  "select"
  "textarea"
  "button"
]

isFormElement = (element) ->
  return false unless element[0]?
  hasName = (element.attr 'name') or (element.attr 'id')
  (element[0].tagName.toLowerCase() in formTags) and hasName

getForm = (element) ->
  element ?= @element
  return element if element.is 'form'
  (element.find 'form').eq 0

eventFn = (fn) ->
  (event) ->
    fn {
      event: event,
      element: $(event.target),
      stop: ->
        event.preventDefault()
    }

submit = (fn, element) ->
  form = getForm.call @, element
  form.submit (eventFn fn)

reset = (fn, element) ->
  form = getForm.call @, element
  form.on 'reset', (eventFn fn)

toObject = (element) ->
  element ?= @element
  mapElement = (elem) ->
    obj = {}
    name = (elem.attr 'name') or (elem.attr 'id')
    obj[name] = elem.val()
    hashMap obj

  (reduce into,
    (map mapElement,
      (filter isFormElement,
        (map $,
          (element.find formTags.join ', ').toArray()))))

module.exports = {
  submit
  reset
  toObject
  getForm
}
