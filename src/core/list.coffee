'use strict'

{first, rest, cons} = require '../protocol/list'
{lazySeq} = require 'lazySeq'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


map = (fn, list) ->
  if (first list) is null
    null
  else
    (cons (fn (first list)), (lazySeq -> map fn, (rest list)))

reduce = (fn, list, acculimator) ->
  item = (first list)
  if item is null
    acculimator
  else
    acculimator = if acculimator? then (fn item acculimator) else item
    (reduce fn (rest list) acculimator)

filter = (pred, list) ->
  item = (first list)
  if item is null
    null
  else
    if (pred item)
      (cons item, (lazySeq -> filter pred, (rest list)))
    else
      (filter pred, (rest list))

module.exports = {
  map,
  reduce,
  filter
}
