'use strict'

{css, data} = require '../protocol/element'
{map} = require './list'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

loadNode = (node) ->
  (data node, "cosy")

read = (node, env) ->
  (set env,
    (map loadNode,
      (css "[data-cosy]", node)))
  env
