'use strict'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


apply = (ctx, fn) ->
  (args...) ->
    fn.apply ctx, args

container = (name, element) ->
  element ?= @element
  element.closest "[data-container=#{name}]"

roles = (name, element) ->
  element ?= @element
  element.find "[data-role=#{name}]"

role = (name, element) ->
  (roles.call @, name, element).eq 0

query = (selector) ->
  $(selector)

eventFn = (fn) ->
  (event) ->
    fn {
      event: event,
      element: $(event.target),
      stop: ->
        event.preventDefault()
    }

onRoleEvent = (element, role, event, fn) ->
  element.on event, "[data-role=#{role}]", (eventFn fn)

onStdEvent = (element, event, fn) ->
  element.on event, (eventFn fn)

onEvent = (args...) ->
  if args.length is 2
    onStdEvent @element, args...
  else
    onRoleEvent @element, args...

onEventDepreciated = (args...) ->
  console.log '`on` is depreciated, please use `onEvent`'
  onEvent.apply @, args

module.exports = {
  container
  role
  roles
  query
  onEvent
  "on": onEventDepreciated
}
