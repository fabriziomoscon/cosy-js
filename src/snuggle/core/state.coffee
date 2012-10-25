'use strict'

{ref, watchRef} = require '../../core/reference'
{get, set} = require '../../protocol/mutable'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


removeState = (element, name) ->
  element.addClass "is-not-#{name}"
  element.removeClass "is-#{name}"
  element.removeAttr "data-is-#{name}"

addState = (element, name) ->
  element.addClass "is-#{name}"
  element.removeClass "is-not-#{name}"
  element.attr "data-is-#{name}", true

class State
  constructor: (element, name, def) ->
    value = ref()
    @on = ->
      set value, true
    @off = ->
      set value, false
    @toggle = ->
      set value, !(get value)
    @get = ->
      get value

    watchRef value, ->
      if get value
        addState element, name
      else
        removeState element, name

    set value, def

state = (name, def, element) ->
  element ?= @element
  new State element, name, def

module.exports = state
