'use strict'

list = require '../protocol/list'
{extend} = require 'protocol'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

class LazySeq
  constructor: (promisem, head) ->
    @promise = promise
    @head = (head ?= null)

isLazySeq = (variable) ->
  variable instanceof LazySeq

lazySeq = (promise, head) ->
  new LazySeq promise, head

module.exports = {
  lazySeq
}

extend list, isLazySeq, {
  first: (sequence) -> sequence.head
  rest: (sequence) -> sequence.promise()
  conj: (sequence, item) -> lazySeq sequence, item
}
