'use strict'

map = require '../protocol/map'
list = require '../protocol/list'
{extend} = require './protocol'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Hash Map class
# @private
class HashMap
  constructor: (map) ->
    (this[key] = value for own key,value of map) if map?

# Hash Map Item class
# @private
class HashMapItem

# Checks if a hash map (or an object) is empty
#
# @param [HashMap] map
# @return [boolean]
isEmpty = (map) ->
  for own key of map
    return false
  true

# Create a new hash map, optionally setting the initial value
#
# @param [Object] map
# @return [HashMap]
hashMap = (map) ->
  new HashMap map

# Create a new hash map item
#
# @param [string] key
# @param [mixed] value
# @return [HashMapItem]
hashMapItem = (key, value) ->
  item = new HashMapItem
  item[0] = key
  item[1] = value
  item

# Checks for a HashMap
#
# @param [mixed] map
# @return [boolean]
isHashMap = (map) ->
  map instanceof HashMap

# Checks for a HashMapItem
#
# @param [mixed] item
# @return [boolean]
isHashMapItem = (item) ->
  item instanceof HashMapItem

module.exports = {
  hashMap
}

# Extend the map protocol (HashMap)
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

# Extend the map protocol  (HashMapItem)
extend map, isHashMapItem,
  key: (item) ->
    item[0]
  value: (item) ->
    item[1]

# Extend the list protocol (HashMap)
extend list, isHashMap,
  first: (col) ->
    for own key, value of col
      return hashMapItem key, value
    null
  rest: (col) ->
    colFirst = (list.first col)
    if colFirst?
      (map.dissoc col, (map.key colFirst))
    else
      null
  conj: (col, item) ->
    if item is null
      col
    else
      if isHashMapItem item
        (map.assoc col, (map.key item), (map.value item))
      else
        {0: key, 1: value} = list.first item
        list.conj (map.assoc col, key, value), list.rest item
