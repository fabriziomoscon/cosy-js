
# Dependencies
colors = require 'colors'
{exec} = require 'child_process'
path = require 'path'

# Paths
paths =
  config: './test/config'
  lib: './lib'
  nodebin: './node_modules/.bin'
  src: './src'
  test: './test'
  unitTest: './test/unit'
  integTest: './test/integration'

# Build JavaScript
desc 'This builds JavaScript from the CoffeeScript source'
task 'build', ['lint', 'test'], ->
  console.log 'Building JavaScript:'.cyan
  exec "#{paths.nodebin}/coffee -o #{paths.lib} #{paths.src}", (error, stdout, stderr) ->
    if error is null
      console.log 'Built!'.green
    else
      console.log stderr
      fail()
    complete()
, async: true

# Run CoffeeLint
desc 'This runs CoffeeLint on the CoffeeScript source'
task 'lint', ->
  console.log 'Linting:'.cyan
  exec getLintCommand(), (error, stdout, stderr) ->
    if stderr is ''
      console.log stdout
    else
      console.log stderr
      fail()
    complete()
, async: true

# Run unit tests
desc 'This runs all unit tests'
task 'test', (filePath) ->
  if filePath?
    filePath = path.join paths.unitTest, filePath
    console.log "Running unit tests for #{filePath}:".cyan
  else
    console.log 'Running unit tests:'.cyan
  exec getTestCommand(path: filePath), (error, stdout, stderr) ->
    if error is null
      console.log stdout
    else
      console.log stderr
      fail()
    complete()
, async: true

# Run integration tests
desc 'This runs all integration tests'
task 'test-integ', (filePath) ->
  if filePath?
    filePath = path.join paths.integTest, filePath
    console.log "Running integration tests for #{filePath}:".cyan
  else
    filePath = paths.integTest
    console.log 'Running integration tests:'.cyan
  exec getTestCommand(path: filePath), (error, stdout, stderr) ->
    if error is null
      console.log stdout
    else
      console.log stderr
      fail()
    complete()
, async: true

# CI
desc 'This runs all tasks required for CI'
task 'ci', ['lint', 'test', 'test-integ']

# Default task
task 'default', ['build']

# Generate a lint command
getLintCommand = (options = {}) ->
  options.configFile ?= "#{paths.config}/coffeelint.json"
  "#{paths.nodebin}/coffeelint -rf #{options.configFile} #{paths.src}/** #{paths.test}/**"

# Generate a test command
getTestCommand = (options = {}) ->
  options.ui ?= 'tdd'
  options.reporter ?= 'spec'
  options.path ?= paths.unitTest
  "#{paths.nodebin}/mocha --compilers coffee:coffee-script --ui #{options.ui} --reporter #{options.reporter} --globals jQuery,$ --colors --recursive #{options.path}"
