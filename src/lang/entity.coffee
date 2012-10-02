'use strict'

{defProtocol, dispatch, extend} = require '../core/protocol'
{assoc, dissoc, get} = require '../protocol/map'
element = require '../protocol/element'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


class Entity
  constructor: (name, id, node) ->
    @name = name
    @id = id
    @node = node

isEntity = (type) ->
  type instanceof Entity

proto = defProtocol {
  update: dispatch (entity, newValue) ->
  remove: dispatch (entity) ->
  name: dispatch (entity) ->
  id: dispatch (entity) ->
}

extend proto, isEntity,
  update: (entity, newValue) ->
    set entity, newValue
  remove: (entity) ->
    node = entity.node
    element.remove node
  name: (entity) ->
    entity.name
  id: (entity) ->
    entity.id

module.exports =
  entity: (frame, name, id) ->
    assoc frame, name, (new Entity name, id, (get frame, '__node'))
  update: (frame, entity, newValue) ->
    proto.update entity, newValue
    frame
  remove: (frame, entity) ->
    newFrame = dissoc frame, (name entity)
    proto.remove entity
    newFrame