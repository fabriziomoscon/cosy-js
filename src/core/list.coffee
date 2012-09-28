'use strict'

{first, rest, cons} = require '../protocol/list'
{lazySeq} = require './lazySeq'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Returns a lazy sequence applying fn to each element of list
#
# @param [function] fn
# @param [list] list
map = (fn, list) ->
  if list is null
    null
  else
    (cons (fn (first list)), (lazySeq -> map fn, (rest list)))

# Reduces a list by applying fn
#
# @param [function] fn
# @param [list] list
# @param [mixed] accum
reduce = (fn, list, accum) ->
  if list is null
    accum
  else
    item = (first list)
    accum = if accum? then (fn item, accum) else item
    (reduce fn, (rest list), accum)

# Returns a lazy sequence containin element in list for which pred returns true
#
# @param [function] pred
# @param [list] list
filter = (pred, list) ->
  if list is null
    null
  else
    item = (first list)
    if (pred item)
      (cons item, (lazySeq -> filter pred, (rest list)))
    else
      (filter pred, (rest list))

module.exports = {
  map,
  reduce,
  filter
}
