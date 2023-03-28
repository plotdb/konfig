module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: [
      {name: "ldbutton", version: "main", path: "index.min.css", global: true}
      {name: "ldcolor", version: "main", path: "index.min.js", async: false}
      {name: "ldslider", version: "main", path: "index.min.js", async: false}
      {name: "ldslider", version: "main", path: "index.min.css", global: true}
      {name: "@loadingio/ldcolorpicker", version: "main", path: "index.min.js", async: false}
      {name: "@loadingio/ldcolorpicker", version: "main", path: "index.min.css"}
      {name: "@loadingio/vscroll", version: "main", path: "index.min.js"}
      {name: "ldpalettepicker", version: "main", path: "index.min.css", global: true}
      {name: "ldpalettepicker", version: "main", path: "index.min.js"}
    ]
  init: ({root, context, pubsub, data, i18n, manager}) ->
    {ldview,ldcolor,ldpp,ldcover} = context
    obj =
      default: data.default or ldpp.default-palette
      pal: data.default or ldpp.default-palette
    pubsub.fire \init, do
      get: -> obj.pal
      set: ->
        obj.pal = it
        view.render!
      default: -> obj.default
      meta: -> obj.default = it.default or ldpp.default-palette
    root = ld$.find root, '[plug=config]', 0
    view = new ldview do
      root: root
      action: click:
        ldp: ({node}) ~>
          action = node.getAttribute \data-action or \edit
          Promise.resolve!
            .then ->
              if obj.ldpp => return
              pals = if Array.isArray(data.palettes) => data.palettes
              else if typeof(data.palettes) == \string => ldpp.get data.palettes
              else null
              p = if pals => Promise.resolve pals
              else
                manager.rescope.load([
                  {name: "ldpalettepicker", version: "main", path: "index.min.js", async: false}
                  {name: "ldpalettepicker", version: "main", path: "all.palettes.js"}
                ])
                  .then ({ldpp}) ~> ldpp.get \all
              p
                .then (pals) ~>
                  obj.ldpp = new ldpp {
                    root: view.get('ldcv'), ldcv: {in-place:false}, use-clusterizejs: true, i18n: i18n
                    palette: data.palette, palettes: pals, use-vscroll: true
                  }
            .then ->
              if action == \edit => obj.ldpp.edit obj.pal
              else obj.ldpp.tab \view
              obj.ldpp.get!
            .then ->
              if !it => return
              obj.pal = it
              view.render \color
              pubsub.fire \event, \change, obj.pal

      handler:
        color:
          list: -> obj.{}pal.[]colors.map (d,i) -> {_idx: i} <<< ldcolor.hsl(d)
          key: -> it._idx
          handler: ({node,data}) -> node.style.backgroundColor = ldcolor.web data
    view.render!
