'use strict'

list = require '../protocol/list'
{extend} = require './protocol'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Lazy Sequence class
class LazySeq
  constructor: (promise, head) ->
    @promise = promise
    @head = (head ?= null)

# Type checker for lazy sequence
#
# @param [mixed] variable
isLazySeq = (variable) ->
  variable instanceof LazySeq

# Constructor for a lazy sequence
lazySeq = (promise, head) ->
  new LazySeq promise, head

# Extend list protocol
extend list, isLazySeq,
  first: (sequence) ->
    unless sequence.head?
      seq = sequence.promise()
      sequence.head = list.first seq
      sequence.promise = -> list.rest seq
    sequence.head

  rest: (sequence) ->
    list.first sequence
    sequence.promise()

  conj: (sequence, item) ->
    sequence.head = item
    sequence

# Exports
module.exports = {
  lazySeq
}

