'use strict'

{defProtocol, dispatch, extend} = require '../core/protocol'
{isArr} = require '../core/native/array'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


module.exports = proto = defProtocol {
  first: dispatch (list) ->
  second: (list) -> proto.first (proto.rest list)
  rest: dispatch (list) ->
  conj: dispatch (list, item) ->
  cons: (item, list) -> (proto.conj list, item)
  into: (to, from) ->
    if from isnt null
      proto.into (proto.conj to, (proto.first from)), (proto.rest from)
    else
      to
}

# Native types

# Null
extend proto, ((list) -> list is null),
  first: -> null
  rest: -> null
  conj: (list, item) -> [item]

# Array
extend proto, isArr,
  first: (list) -> if list.length? and list.length then list[0] else null
  rest: (list) -> if list.length > 1 then list.splice(1) else null
  conj: (list, item) ->
    newList = list.splice 0
    newList.push item
    newList

