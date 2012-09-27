'use strict'

{defProtocol, dispatch, extend} = require '../core/protocol'
{isArr} = require '../core/native/array'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


module.exports = proto = defProtocol {
  first: dispatch (list) ->
  rest: dispatch (list) ->
  cons: dispatch (list, item) ->
}

# Native types

# Array
extend proto, isArr,
  first: (list) -> if list.length then list[0] else null
  rest: (list) -> if list.length > 1 then list.splice(1) else null
  cons: (list, item) ->
    newList = list.splice 0
    newList.push item
    newList

# Object
# @todo
