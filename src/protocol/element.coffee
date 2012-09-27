{defProtocol, dispatch, extend} = require '../core/protocol'
{ref, watchRef} = require '../core/reference'
{set} = require '../protocol/mutable'
{isFn, assertFn} = require '../core/native/function.coffee'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Is the value a valid jQuery element
#
# @private
# @param [mixed] value
# @return [Boolean]
isJqueryElement = (value) ->
  (isFn value.data) and
  (isFn value.val)


# Exports
module.exports = protocol = defProtocol {
  cosy: (element) -> (protocol.data element, 'cosy')
  data: dispatch (element, key) ->
  value: dispatch (element, value) ->
}


# Extend protocol for jQuery
extend protocol, isJqueryElement,
  data: (element, key) ->
    watchRef (set ref(), (element.data key)), (reference) ->
      element.data key, (get reference)
  value: (element, key) ->
    watchRef (set ref(), (element.data key)), (reference) ->
      element.val key, (get reference)
