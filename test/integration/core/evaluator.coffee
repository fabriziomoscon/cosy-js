'use strict'

{assert} = require 'chai'
jQuery = require 'jquery'
{first} = require '../../../src/protocol/list'
{env} = require '../../../src/core/environment'
reader = require '../../../src/core/reader'
dom = require '../../../src/dom/reader'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License

# Tests
suite 'Core Reader:', ->
  evaluator = require '../../../src/core/evaluator'
  environment = null
  setup ->
    html = '''
<body>
  <div data-cosy="" data-cosy-entity="foo">
    <button data-cosy="" data-cosy-event-click="remove foo">Remove</button>
  </div>
</body>
'''
    environment = env console, jQuery
    ast = reader.read jQuery html

    environment = evaluator.apply ast, environment

  test 'Nex environment is an object', ->
    assert.isObject environment