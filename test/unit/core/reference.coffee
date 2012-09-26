
# Dependencies
{assert} = require 'chai'


# Tests
suite 'reference module', ->
  {ref, isRef, getRef, setRef, watchRef} = require '../../../src/core/reference'

  test 'string is not a reference', ->
    assert.isFalse (isRef 'foo')

  test 'empty object is not a reference', ->
    assert.isFalse (isRef {})

  test 'ref returns a reference', ->
    assert.isTrue (isRef ref())


  suite 'get and set', ->
    val = null

    setup ->
      val = ref()

    test 'getRef is null', ->
      assert.isNull (getRef val)

    test 'setRef sets reference value', ->
      assert.strictEqual 'foo', (getRef (setRef val, 'foo'))

    test 'getRef with an invalid reference', ->
      assert.throws ->
        getRef {}
      , /Invalid reference/

    test 'setRef with an invalid reference', ->
      assert.throws ->
        setRef {}, 'foo'
      , /Invalid reference/


  suite 'Watch changes', ->
    val = null

    setup ->
      val = ref()

    test 'watcher is called when reference changes', ->
      newvalue = null
      callback = (reference) ->
        newvalue = getRef reference
      watchRef val, callback
      setRef val, 'foo'
      assert.strictEqual 'foo', newvalue