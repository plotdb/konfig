module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: [ {name: \ldfile} ]
  init: ({root, context, data, pubsub}) ->
    {ldview, ldfile} = context
    @_meta = data
    pubsub.fire \init, do
      get: -> view.get('input').value or ''
      set: -> view.get('input').value = it or ''
      default: -> []
      meta: ~> @_meta = it
    view = new ldview do
      root: root
      init: input: ({node}) ~> if @_meta.multiple => node.setAttribute \multiple, true
      action: change:
        input: ({node}) ->
          ps = [node.files[v] for v from 0 til node.files.length]
            .map (v) ->
              ldfile.fromFile v, \dataurl
                .then -> it.result
          Promise.all ps
            .then (files) ->
              pubsub.fire \event, \change, files
