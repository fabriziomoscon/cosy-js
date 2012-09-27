'use strict'

# Dependencies
{assert} = require 'chai'
{spy} = require 'sinon'


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
  	class myType
  		a: 1
  	myVar = new myType

  	setup ->
  		extend proto, ((type) -> type instanceof myType),
  		  myFn1: (self, x, y) -> self.a = x + y
  		  myFn2: (self, x) -> self.a = x

  	test 'myFn1', ->
  		(proto.myFn1 myVar, 2, 3)
  		assert.strictEqual 5, myVar.a

  	test 'myFn2', ->
  		(proto.myFn2 myVar, 2)
  		assert.strictEqual 2, myVar.a

  	suite 'Extending again:', ->
	  	class myOtherType
	  		a: 1
	  	myOtherVar = new myOtherType

	  	setup ->
	  		extend proto, ((type) -> type instanceof myOtherType),
	  		  myFn1: (self, x, y) -> self.a = x - y
	  		  myFn2: (self, x) -> self.a = -x

	  	test 'myFn1 myType', ->
	  		(proto.myFn1 myVar, 2, 3)
	  		assert.strictEqual 5, myVar.a

	  	test 'myFn2 myType', ->
	  		(proto.myFn2 myVar, 2)
	  		assert.strictEqual 2, myVar.a

	  	test 'myFn1 myOtherType', ->
	  		(proto.myFn1 myOtherVar, 2, 3)
	  		assert.strictEqual -1, myOtherVar.a

	  	test 'myFn2 myOtherType', ->
	  		(proto.myFn2 myOtherVar, 2)
	  		assert.strictEqual -2, myOtherVar.a
