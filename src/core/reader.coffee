'use strict'

{css, data} = require '../protocol/element'
{key, value} = require '../protocol/map'
{into, second} = require '../protocol/list'
{hashMap} = require './hashMap'
{map} = require './list'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

getData = (attr) ->
  data = {}
  data[second /^data-cosy-(.*)/.exec (key attr)] = value attr
  hashMap data

cosyData = (attr) ->
  (/^data-cosy-/.exec (key attr))?

parseData = (node) ->
  (reduce into,
    (map getData,
      (filter cosyData, (attrs node))))

# Parses all
# Loads a dom node
#
# @param [element] node
# @return [map]
loadNode = (node) ->
  {
    data: (into (cosy node), (parseData node))
    node: node
  }

# Returns a lazy sequence of all the cosy nodes in a dom node
#
# @param [element] node
# @param [Environment] env
read = (node) ->
  (map loadNode, (css node, "[data-cosy]"))

module.exports = {
  read
}
