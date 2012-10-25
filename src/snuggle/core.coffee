'use strict'

query = require './core/query'
ref = require './core/reference'
template = require './core/template'

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
  state: require './core/state'
  template: template.template
  render: template.render
  global: require './core/global'
