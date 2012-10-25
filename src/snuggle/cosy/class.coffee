'use strict'

{isFn} = require '../../core/native/function'
{evaluate, use} = require '../../core/evaluator'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


classControl = (constructor) ->
  (args...) ->
    if @isInitialising
      new constructor @, args...
    else if isFn @update
      @update args...

cosyClass = (frame, constructor, args...) ->
  control = classControl constructor
  evaluate (['control', control].concat args), frame

module.exports = cosyClass