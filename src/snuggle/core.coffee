'use strict'

query = require './core/query'
ref = require './core/reference'
template = require './core/template'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


module.exports =
  container: query.container
  role: query.role
  roles: query.roles
  query: query.query
  list: require './core/list'
  "on": query.on
  set: ref.set
  get: ref.get
  notify: ref.notify
  copy: ref.copy
  form: require './core/form'
  html: require './core/html'
  state: require('./core/state').state
  template: template.template
  render: template.render
  renderRaw: template.renderRaw
  global: require './core/global'
  watch: ref.watch
  watchRef: ref.watchRef
