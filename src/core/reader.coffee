'use strict'

{css, data} = require '../protocol/element'
{key, value} = require '../protocol/map'
{into, second} = require '../protocol/list'
{map} = require './list'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


getData = (attr) ->
  data = {}
  data[second /^data-cosy-(.*)/.exec (key attr)] = value attr
  data

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
    data: (into (data node, "cosy"), (parseData node))
    node: node
  }

# Read a node into env
#
# @param [element] node
# @param [Environment] env
read = (node, env) ->
  (set env,
    (map loadNode,
      (css "[data-cosy]", node)))
  env

module.exports = {
  read
}