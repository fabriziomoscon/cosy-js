'use strict'

{css, data, cosy, attrs} = require '../protocol/element'
{key, value} = require '../protocol/map'
{into, second, rest} = require '../protocol/list'
{hashMap} = require './hashMap'
{map, reduce, filter} = require './list'
{get} = require '../protocol/mutable'
dom = require '../dom/reader'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

getData = (node, attr) ->
  parts = /^data-(cosy-(.*))/.exec (key attr)
  name = parts[2]
  dataName = parts[1]
  getObject = (name, value) ->
    result = {}
    parts = /^([^-]+)(-(.*))?/.exec name
    if parts[3]?
      result[parts[1]] = getObject parts[3], value
    else
      result[name] = value
    hashMap result
  getObject name, data node, dataName

cosyData = (attr) ->
  (/^data-cosy-/.exec (key attr))?

parseData = (node) ->
  result = cosy node
  if result is '' or result?
    result = hashMap {}
  (into result,
    (reduce into,
      (map ((attr) -> getData node, attr),
        (filter cosyData, (attrs node)))))

# Parses all
# Loads a dom node
#
# @param [element] node
# @return [map]
loadNode = (node) ->
  return null unless node?
  {
    cosy: parseData node.node
    node: node.node
    children: map loadNode, node.children
  }

# Returns a lazy sequence of all the cosy nodes in a dom node
#
# @param [element] node
# @param [Environment] env
read = (node) ->
  loadNode dom.read node, "[data-cosy]"

module.exports = {
  read
}
