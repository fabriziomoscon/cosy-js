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

# Turn a sequence into a plain array
#
# @param [list] seq
# @return [Array]
vec = (seq) ->
  result = []
  doSeq ((item) -> result.push item), seq
  result

# Perform a loop without retcursion (trampoline)
#
# @param [Function] fn
# @return [null]
doLoop = (fn) ->
  while fn?
    result = fn()
    fn = result?.recur
  null

# Cause a loop to recur on a function
#
# @param [Function] fn
# @return [Object]
recur = (fn) ->
  return {recur: fn}

# Call fn on all elements of a sequence
#
# @param [Function] fn
# @param [list] seq
# @return null
doSeq = (fn, seq) ->
  return null unless seq?
  doLoop ->
    fn (first seq)
    recur -> doSeq fn, (rest seq)

module.exports = {
  map,
  reduce,
  filter,
  take,
  drop,
  vec,
  doSeq
}
