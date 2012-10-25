'use strict'

attach = (frame) ->
  frame.__node[0].frame = frame
  frame

module.exports = attach
