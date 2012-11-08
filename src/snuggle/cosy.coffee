'use strict'

{use} = require '../core/evaluator'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

deprecatedMsgSent = false
nsDeprecated = (args...) ->
  if deprecatedMsgSent is false
    console.log '`ns` is deprecated, please use `import`'
    deprecatedMsgSent = true
  use args...

module.exports =
  control: require './cosy/control'
  class: require './cosy/class'
  props: require './cosy/props'
  attach: require './cosy/attach'
  call: require './cosy/call'
  import: use
  ns: nsDeprecated
