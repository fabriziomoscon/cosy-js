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

createEntity = (name, id, node) ->
  new Entity name, id, node

entity = (frame, constructor, name, id) ->
  assoc frame, name, (constructor name, id, (get frame, '__node'))

module.exports =
  entity: (frame, args...) ->
    args.unshift createEntity if args.length < 4
    entity frame, args...
  update: (frame, entity, newValue) ->
    proto.update entity, newValue
    frame
  remove: (frame, entity) ->
    newFrame = dissoc frame, (proto.name entity)
    proto.remove entity
    newFrame
