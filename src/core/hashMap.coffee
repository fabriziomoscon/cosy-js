'use strict'

map = require '../protocol/map'
list = require '../protocol/list'
{extend} = require './protocol'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


class HashMap
  constructor: (map) ->
    (this[key] = value for own key,value of map) if map?

class HashMapItem

isEmpty = (map) ->
  for own key of map
    return false
  true

hashMap = (map) ->
  new HashMap map

hashMapItem = (key, value) ->
  item = new HashMapItem
  item[0] = key
  item[1] = value
  item

isHashMap = (map) ->
  map instanceof HashMap

isHashMapItem = (item) ->
  item instanceof HashMapItem

module.exports = {
  hashMap
}

extend map, isHashMap,
  assoc: (col, key, value) ->
    newMap = hashMap col
    if isHashMap col[key]
      newMap[key] = list.into col[key], value
    else
      newMap[key] = value
    newMap
  dissoc: (col, key) ->
    newMap = hashMap col
    delete newMap[key]
    if not isEmpty newMap then newMap else null
  get: (col, key, def) ->
    def ?= null
    if col[key]? then col[key] else def
  find: (col, key) ->
    if col[key]?
      hashMapItem key, col[key]
    else
      null

extend map, isHashMapItem,
  key: (item) ->
    item[0]
  value: (item) ->
    item[1]

extend list, isHashMap,
  first: (col) ->
    for own key, value of col
      return hashMapItem key, value
    null
  rest: (col) ->
    (map.dissoc col, (map.key (list.first col)))
  conj: (col, item) ->
    if item is null
      col
    else
      if isHashMapItem item
        (map.assoc col, (map.key item), (map.value item))
      else
        {0: key, 1: value} = list.first item
        list.conj (map.assoc col, key, value), list.rest item
