module.exports =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: [
      {url: "/assets/lib/ldcolor/main/index.min.js", async: false}
      {url: "/assets/lib/ldslider/main/index.min.css", type: \css}
      {url: "/assets/lib/ldslider/main/index.min.js", async: false}
      {url: "/assets/lib/@loadingio/ldcolorpicker/main/index.min.css", type: \css}
      {url: "/assets/lib/@loadingio/ldcolorpicker/main/index.min.js", async: false}
      {url: "/assets/lib/ldpalettepicker/main/index.min.css", type: \css}
      {url: "/assets/lib/ldpalettepicker/main/index.min.js"}
    ]
  init: ({root, context, pubsub, data}) ->
    {ldview,ldcolor,ldpp,ldcover} = context
    obj = {pal: null}
    pubsub.fire \init, do
      data: data
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
        obj.ldpp = new ldpp root: node, ldcv: true
        obj.pal = obj.ldpp.ldpe.get-pal!
      handler:
        color:
          list: -> obj.{}pal.[]colors
          key: -> ldcolor.web(it)
          handler: ({node,data}) -> node.style.backgroundColor = ldcolor.web data
    setTimeout (-> view.render!), 2000
