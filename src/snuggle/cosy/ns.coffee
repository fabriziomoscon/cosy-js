'use strict'

{isStr} = require '../../core/native/string'
{vec} = require '../../core/list'
{first, rest} = require '../../protocol/list'
{use} = require '../../core/evaluator'

findNs = (frame, name, parent) ->
  if frame[name]?
    frame[name].__parentNS = parent
    frame[name]
  else
    parts = name.split /[.]/
    if frame[first parts]?
      frame[first parts].__parentNS = parent
      findNs (use frame, frame[first parts]), ((vec rest parts).join '.'), frame[first parts]
    else
      # todo capture the ns path for better errors
      throw new Error 'Namespace ' + name + ' not found'

ns = (frame, name) ->
  if isStr name
    importNs = findNs frame, name
  else
    importNs = name
  use frame, importNs

module.exports = ns
