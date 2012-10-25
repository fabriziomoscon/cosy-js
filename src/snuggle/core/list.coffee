'use strict'

{isArr} = require '../../core/native/array'
{isRef} = require '../../core/reference'
{get, set} = require '../../protocol/mutable'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


isList = isArr

count = (list) ->
  return count get list if isRef list
  if list.length?
    list.length
  else
    0

push = (list, item) ->
  if isRef list
    lst = (get list) or []
    set list, lst.concat [item]
  else
    list.push item

removeItem = (list, item) ->
  if isRef list
    lst = get list
    removeItem lst, item
    set list, lst
  else
    (list[i..i] = [] if item is x) for x, i in list

remove = (list, index) ->
  if isRef list
    lst = get list
    remove lst, index
    set list, lst
  else
    list[index..index] = []

contains = (list, item) ->
  return false unless list?
  if isRef list
    return contains (get list), item
  else
    (return true if item is x) for x in list
  false

module.exports = {
  count
  isList
  push
  remove
  removeItem
  contains
}
