'use strict'

{isFn} = require '../../core/native/function'
{evaluate, use} = require '../../core/evaluator'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Build a class control
#
# @param [Function] constructor
# @return [Function]
classControl = (constructor) ->
  (args...) ->
    if @isInitialising
      @isInitialising = false
      @frame["this"] = new constructor @, args...
    else if isFn @update
      @update args...

# Instantial a cosy class
#
# @param [HashMap] frame
# @param [Function] constructor
# @param [Array] args
# @return [HashMap]
cosyClass = (frame, constructor, args...) ->
  control = classControl constructor
  frame.control frame, control, args...

# Treat all refs and globals as strings
cosyClass.raw = /^&?[%@].+$/

module.exports = class: cosyClass
