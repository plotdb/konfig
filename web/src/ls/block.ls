context = ->
  Promise.resolve!
    .then ~>
      @def = {}
      config-editor.types.map (n) ~> @def[n] = {name: n, type: n, group: n.substring(0,1) }
      @ce = ce = new config-editor def: @def, root: container
      ce.init!
    .then ~> @ce.parse!
    .then ~> @ce.render!

    .then -> console.log \done.

  @

new context!

