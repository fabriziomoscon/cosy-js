'use strict'

{defProtocol, dispatch, extend} = require '../core/protocol'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

module.exports = protocol = defProtocol
  # Return the key of a map item
  # @todo move into own protocol
  #
  # @param [MapItem] mapItem
  # @return [string]
  key: dispatch (mapItem) ->


  # Return the value of a map item
  # @todo move into own protocol
  #
  # @param [mapItem] mapItem
  # @return [mixed]
  value: dispatch (mapItem) ->


  # Return a map with key/value added to map
  #
  # @param [map] map
  # @param [string] key
  # @param [mixed] value
  # @return [map]
  assoc: dispatch (map, key, value) ->


  # Return a map with all the keys from map excluding key
  #
  # @param [map] map
  # @param [string] key
  # @return [map]
  dissoc: dispatch (map, key) ->


  # Return the value associated with key or null
  #
  # @param [map] map
  # @param [string] key
  # @return [mixed]
  get: dispatch (map, key) ->


  # Return the map item associated with key or null
  #
  # @param [map] map
  # @param [string] key
  # @return [MapItem]
  find: dispatch (map, key) ->
