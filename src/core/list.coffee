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
reduce = (fn, list, accum = null) ->
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
    if item? and (pred item)
      (cons item,
        (lazySeq ->
          filter pred, (rest list)))
    else
      (filter pred, (rest list))

# Returns a lazy sequence of then first n items in a sequence
#
# @param [integer] n
# @param [list] list
take = (n, list) ->
  if list is null or n < 1
    null
  else
    (cons (first list),
      (lazySeq ->
        take n-1, (rest list)))

# Returns a lazy sequence of all but the first n items in list
#
# @param [integer] n
# @param [list] list
drop = (n, list) ->
  step = (n, list) ->
    if n < 1
      list
    else
      step n-1, rest list
  lazySeq -> step n, list

vec = (seq) ->
  if seq isnt null
    (cons (first seq), (vec (rest seq)))
  else
    null

module.exports = {
  map,
  reduce,
  filter,
  take,
  drop,
  vec
}
