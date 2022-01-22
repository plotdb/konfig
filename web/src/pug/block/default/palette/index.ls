module.exports =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: [
      {name: "ldcolor", version: "main", path: "index.min.js", async: false}
      {name: "ldslider", version: "main", path: "index.min.js", async: false}
      {name: "ldslider", version: "main", path: "index.min.css"}
      {name: "@loadingio/ldcolorpicker", version: "main", path: "index.min.js", async: false}
      {name: "@loadingio/ldcolorpicker", version: "main", path: "index.min.css"}
      {name: "@loadingio/vscroll", version: "main", path: "index.min.js"}
      {name: "ldpalettepicker", version: "main", path: "index.min.css"}
      {name: "ldpalettepicker", version: "main", path: "index.min.js", async: false}
      {name: "ldpalettepicker", version: "main", path: "all.palettes.js"}
    ]
  init: ({root, context, pubsub, data, i18n}) ->
    {ldview,ldcolor,ldpp,ldcover} = context
    obj = {pal: data.palette or ldpp.default-palette}
    pubsub.fire \init, do
      get: -> obj.pal
      set: ->
        obj.pal = it
        view.render!
    root = ld$.find root, '[plug=config]', 0
    view = new ldview do
      root: root
      action: click:
        ldp: ->
          if !obj.ldpp =>
            pals = if Array.isArray(data.palettes) => data.palettes
            else if typeof(data.palettes) == \string => ldpp.get data.palettes
            else ldpp.get('all')
            obj.ldpp = new ldpp {
              root: view.get('ldcv'), ldcv: true, use-clusterizejs: true, i18n: i18n
              palette: data.palette, palettes: pals, use-vscroll: true
            }
          obj.ldpp.get!then ->
            if !it => return
            obj.pal = it
            view.render \color
            pubsub.fire \event, \change, obj.pal
      handler:
        color:
          list: -> obj.{}pal.[]colors
          key: -> ldcolor.web(it)
          handler: ({node,data}) -> node.style.backgroundColor = ldcolor.web data
    view.render!
