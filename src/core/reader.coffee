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
    if parts? and parts[3]?
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
  new Cosy (into result,
    (reduce into,
      (map ((attr) -> getData node, attr),
        (filter cosyData, (attrs node)))))

class Tree
  constructor: (_tree) ->
    @.root = _tree.root
    @.children = _tree.children

class TreeNode
  constructor: (_node) ->
    @.cosy = _node.cosy
    @.element = _node.element

class Cosy
  constructor: (_cosy) ->
    @[_key] = _value for own _key, _value of _cosy

isCosy = (cosy) ->
  cosy instanceof Cosy

isTree = (tree) ->
  tree instanceof Tree

isTreeNode = (root) ->
  root instanceof TreeNode

# Loads a dom node
#
# @param [element] node
# @return [map]
loadNode = (node) ->
  # @todo remove knowledge of node impl
  return null unless node?
  new Tree {
    root: new TreeNode {
      cosy: parseData node.node
      element: node.node
    }
    children: map loadNode, node.children
  }

# Returns a lazy sequence of all the cosy nodes in a dom node
#
# @param [element] node
# @param [Environment] env
read = (node) ->
  loadNode dom.read node, "[data-cosy]"

getNode = (ast) ->
  ast.root

getElement = (root) ->
  root.element

getCosy = (root) ->
  root.cosy

getChildren = (ast) ->
  ast.children

module.exports = {
  read,
  isTree,
  isTreeNode,
  isCosy,
  node: getNode,
  cosy: getCosy,
  children: getChildren,
  element: getElement
}
