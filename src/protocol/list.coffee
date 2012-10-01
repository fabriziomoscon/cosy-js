'use strict'

{defProtocol, dispatch, extend} = require '../core/protocol'
{isArr} = require '../core/native/array'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


module.exports = proto = defProtocol {
  # Return the first litem in a list/sequence
  #
  # @param [list] list
  # @return [mixed]
  first: dispatch (list) ->


  # Return the second item in a list/sequence
  #
  # @param [list] list
  # @return [mixed]
  second: (list) -> proto.first (proto.rest list)


  # Return a list of everything but the first item
  #
  # @param [list] list
  # @return [list]
  rest: dispatch (list) ->


  # Return a list conjoining the list with the item
  #
  # @param [list] list
  # @param [mixed] item
  # @return [list]
  conj: dispatch (list, item) ->


  # Return a list composing the list with the item
  #
  # @param [mixed] item
  # @param [list] list
  # @return [list]
  cons: (item, list) -> (proto.conj list, item)


  # Return a list with all the items to to with all the items of from conjoined
  #
  # @param [list] to
  # @param [list] from
  # @return [list]
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

