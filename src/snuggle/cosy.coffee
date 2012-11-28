'use strict'

{use} = require '../core/evaluator'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

deprecatedMsgSent = false

# Import an object into the current frame
#
# @param [Array] args
# @return [HashMap]
nsDeprecated = (args...) ->
  if deprecatedMsgSent is false
    console.log '`ns` is deprecated, please use `import`'
    deprecatedMsgSent = true
  use args...

# Import a set of objects into the current frame
#
# @param [HashMap] frame
# @param [Object] obj
# @param [Array] args
# @return [HashMap]
importObj = (frame, obj, args...) ->
  return frame unless obj?
  frame = use frame, obj
  importObj frame, args...

module.exports =
  control: (require './cosy/control').control
  class: (require './cosy/class').class
  props: (require './cosy/props').props
  attach: (require './cosy/attach').attach
  call: (require './cosy/call')['call']
  partial: require('./cosy/partial').partial
  import: importObj
  ns: nsDeprecated
