<-(->it!) _

block-factory =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: [
      {url: "/assets/lib/ldcover/main/ldcv.css"}
      {url: "/assets/lib/ldcover/main/ldcv.js"}
      {url: "/assets/lib/ldcolor/main/ldcolor.js", async: false}
      {url: "/assets/lib/ldslider/main/ldrs.css"}
      {url: "/assets/lib/ldslider/main/ldrs.js", async: false}
      {url: "/assets/lib/@loadingio/ldcolorpicker/main/ldcp.css"}
      {url: "/assets/lib/@loadingio/ldcolorpicker/main/ldcp.js", async: false}
      {url: "/assets/lib/ldpalettepicker/main/index.css"}
      {url: "/assets/lib/ldpalettepicker/main/index.js"}
    ]
  init: ({root, context, pubsub, data}) ->
    {ldview,ldcolor,ldpp,ldcover} = context
    obj = {pal: null}
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
          obj.ldpp.get!then ->
            if !it => return
            obj.pal = it
            view.render \color
            pubsub.fire \event, \change, obj.pal
      init: ldcv: ({node}) ->
        obj.ldpp = new ldpp {
          root: node, ldcv: true, use-clusterizejs: true
          palette: data.palette, palettes: data.palettes
        }
        obj.pal = obj.ldpp.ldpe.get-pal!
      handler:
        color:
          list: -> obj.{}pal.[]colors
          key: -> ldcolor.web(it)
          handler: ({node,data}) -> node.style.backgroundColor = ldcolor.web data
    view.render!

return block-factory
