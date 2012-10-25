'use strict'

# Dependencies
{spy} = require 'sinon'

# Create a mock jQuery element
mock = ->
  data: spy()
  val: spy()

# Exports
module.exports = {mock}
