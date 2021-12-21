<-(->it!) _

block-factory =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: [
      {name: "@xlfont/load", version: "main", path: "index.min.js"}
      {name: "@xlfont/choose", version: "main", path: "index.min.js"}
      {name: "@xlfont/choose", version: "main", path: "index.min.css", global: true}
    ]
  init: ({root, context, data, pubsub}) ->
    {ldview,ldcover,xfc} = context
    pubsub.fire \init, do
      get: -> obj.font
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
          obj.ldcv = new ldcover root: node
          obj.ldcv.on \toggle.on, -> chooser.render!
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

return block-factory
