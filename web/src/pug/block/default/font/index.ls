module.exports =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: [
      {name: "@xlfont/load", version: "main", path: "index.min.js"}
      {name: "@xlfont/choose", version: "main", path: "index.min.js"}
      {name: "@xlfont/choose", version: "main", path: "index.min.css", global: true}
    ]
  init: ({root, context, data, pubsub}) ->
    {ldview,ldcover,xfc} = context
    # TODO data for get/set should be serializable and backward compatible.
    pubsub.fire \init, do
      get: ->
        if obj.font => obj.font{name, style, weight}
        if typeof(data.default) == \string => {name: data.default} else data.default
      set: ->
        obj.font = it
        view.render \button
    obj = {font: null}
    chooser = new xfc do
      root: root.querySelector('.ldcv'), init-render: true
      meta: 'https://xlfont.maketext.io/meta'
      links: 'https://xlfont.maketext.io/links'
    chooser.init!
    chooser.on \choose, (f) ~> obj.ldcv.set f
    view = new ldview do
      root: root
      init:
        ldcv: ({node}) ->
          obj.ldcv = new ldcover root: node, in-place: false
          obj.ldcv.on \toggle.on, -> debounce 50 .then -> chooser.render!
      action: click:
        button: ({node}) ->
          obj.ldcv.get!
            .then (f) ->
              obj.font = f
              view.render \button
              pubsub.fire \event, \change, f
      text:
        button: ({node}) ->
          if !obj.font => "..." else obj.font.name or "..."
