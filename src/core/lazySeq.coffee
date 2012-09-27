'use strict'

list = require '../protocol/list'
{extend} = require 'protocol'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Lazy Sequence class
class LazySeq
  constructor: (promisem, head) ->
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
  first: (sequence) -> sequence.head
  rest: (sequence) -> sequence.promise()
  conj: (sequence, item) -> lazySeq sequence, item

# Exports
module.exports = {
  lazySeq
}

