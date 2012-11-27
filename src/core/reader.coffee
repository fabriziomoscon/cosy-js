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

# Return a hashmap of the data-cosy part of an attribute
#
# @param [mixed] node
# @param [HashMapItem] attr
# @return [HashMap]
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
  getObject name, (data node, dataName)

# An attribute for the data-cosy prefix
#
# @param [HashMapItem] attr
# @return [boolean]
isCosyData = (attr) ->
  (/^data-cosy-/.exec (key attr))?

# Given a node parse the data attributes for cosy commands
#
# @param [mixed] node
# @return [Cosy]
parseData = (node) ->
  result = cosy node
  if result is ''
    result = hashMap {}
  unless result?
    result = hashMap {}
  new Cosy (into result,
    (reduce into,
      (map ((attr) -> getData node, attr),
        (filter isCosyData, (attrs node)))))

# Tree class
# @private
class Tree
  constructor: (_tree) ->
    @.root = _tree.root
    @.children = _tree.children

# TreeNode class
# @private
class TreeNode
  constructor: (_node) ->
    @.cosy = _node.cosy
    @.element = _node.element

# Cosy class
# @private
class Cosy
  constructor: (_cosy) ->
    @[_key] = _value for own _key, _value of _cosy

# Check for a Cosy class
#
# @param [mixed] type
# @return [boolean]
isCosy = (type) ->
  type instanceof Cosy

# Check for a Tree class
#
# @param [mixed] type
# @return [boolean]
isTree = (type) ->
  type instanceof Tree

# Check for a TreeNode class
#
# @param [mixed] type
# @return [boolean]
isTreeNode = (type) ->
  type instanceof TreeNode

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
read = (node, selector) ->
  selector ?= "[data-cosy]"
  loadNode dom.read node, selector

# Given a tree return the root node
#
# @param [Tree] ast
# @return [TreeNode]
getNode = (ast) ->
  ast.root

# Given a tree node return the element
#
# @param [TreeNode] root
# @return [mixed]
getElement = (root) ->
  root.element

# Given a tree node return the cosy part
#
# @param [TreeNode] root
# @return [Cosy]
getCosy = (root) ->
  root.cosy

# Given a tree return the children
#
# @param [Tree] ast
# @return [list]
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
