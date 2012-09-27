'use strict'

# Dependencies
{assert} = require 'chai'
console = require '../../mock/console.coffee'
domLib = require '../../mock/jQuery.coffee'
{get, set} = require '../../../src/protocol/mutable'

# Tests
suite 'environment:', ->
  env = require '../../../src/core/environment'

  suite 'isEnv:', ->
    test 'string is not an environment', ->
      assert.isFalse (env.isEnv 'foo')

    test 'empty object is not an environment', ->
      assert.isFalse (env.isEnv {})


  suite 'env:', ->
    test 'env returns an environment', ->
      assert.isTrue (env.isEnv env.env(console, domLib))


  suite 'log:', ->
    data = ret = val = null

    setup ->
      data = 'foo'
      val = env.env(console, domLib)
      ret = env.log val, data

    test 'log calls console.log method', ->
      assert.isTrue console.log.calledOnce

    test 'log calls console.log method with data', ->
      assert.isTrue console.log.calledWith data

    test 'log with an invalid environment', ->
      assert.throws ->
        env.log {}, data
      , /Invalid environment/


  suite 'mutable protocols:', ->
    val = null

    setup ->
      val = env.env(console, domLib)

    test 'get on environment is null', ->
      assert.isNull (get val)

    test 'set on environment sets value', ->
      assert.strictEqual 'foo', (get (set val, 'foo'))

    test 'set on environment returns environment', ->
      assert.strictEqual val, (set val, 'foo')
