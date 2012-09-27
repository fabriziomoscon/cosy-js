'use strict'

{assert} = require 'chai'
{spy} = require 'sinon'

# Cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


# Tests
suite 'protocol module', ->
  {defProtocol, extend, dispatch} = require '../../../src/core/protocol'
  proto = null
  setup ->
    proto = defProtocol {
      myFn1: dispatch (x, y, z) ->
      myFn2: dispatch (x, y) ->
    }

  test 'Protocol returns a map of fns', ->
    assert.isFunction proto.myFn1
    assert.isFunction proto.myFn2

  suite 'Unimplemented functions throw:', ->
    test 'myFn1', ->
      assert.throws ->
        proto.myFn1 1, 2, 3
      , /Function not implemented/

    test 'myFn2', ->
      assert.throws ->
        proto.myFn2 1, 2
      , /Function not implemented/

  suite 'Functions called wuth the wrong argument count throw:', ->
    test 'myFn1 too few arguments', ->
      assert.throws ->
        proto.myFn1 1, 2
      , /Invalid invocation/

    test 'myFn2 too few arguments', ->
      assert.throws ->
        proto.myFn1 1
      , /Invalid invocation/

    test 'myFn1 too many arguments', ->
      assert.throws ->
        proto.myFn1 1, 2, 3, 4
      , /Invalid invocation/

    test 'myFn2 too many arguments', ->
      assert.throws ->
        proto.myFn2 1, 2, 3
      , /Invalid invocation/

  suite 'Extending protocol:', ->
    class MyType
      a: 1
    myVar = new MyType

    setup ->
      extend proto, ((type) -> type instanceof MyType),
        myFn1: (self, x, y) -> self.a = x + y
        myFn2: (self, x) -> self.a = x

    test 'myFn1', ->
      (proto.myFn1 myVar, 2, 3)
      assert.strictEqual 5, myVar.a

    test 'myFn2', ->
      (proto.myFn2 myVar, 2)
      assert.strictEqual 2, myVar.a

    suite 'Extending again:', ->
      class MyOtherType
        a: 1
      myOtherVar = new MyOtherType

      setup ->
        extend proto, ((type) -> type instanceof MyOtherType),
          myFn1: (self, x, y) -> self.a = x - y
          myFn2: (self, x) -> self.a = -x

      test 'myFn1 MyType', ->
        (proto.myFn1 myVar, 2, 3)
        assert.strictEqual 5, myVar.a

      test 'myFn2 MyType', ->
        (proto.myFn2 myVar, 2)
        assert.strictEqual 2, myVar.a

      test 'myFn1 MyOtherType', ->
        (proto.myFn1 myOtherVar, 2, 3)
        assert.strictEqual -1, myOtherVar.a

      test 'myFn2 MyOtherType', ->
        (proto.myFn2 myOtherVar, 2)
        assert.strictEqual -2, myOtherVar.a
