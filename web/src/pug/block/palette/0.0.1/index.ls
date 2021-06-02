<-(->it!) _

block-factory =
  pkg:
    name: 'palette', version: '0.0.1'
    dependencies: [
      {url: "/assets/lib/ldcover/main/ldcv.css", type: \css}
      {url: "/assets/lib/ldcover/main/ldcv.js"}
      {url: "/assets/lib/ldcolor/main/ldcolor.js", async: false}
      {url: "/assets/lib/ldslider/main/ldrs.css", type: \css}
      {url: "/assets/lib/ldslider/main/ldrs.js", async: false}
      {url: "/assets/lib/@loadingio/ldcolorpicker/main/ldcp.css", type: \css}
      {url: "/assets/lib/@loadingio/ldcolorpicker/main/ldcp.js", async: false}
      {url: "/assets/lib/ldpalettepicker/main/ldpp.css", type: \css}
      {url: "/assets/lib/ldpalettepicker/main/ldpp.js"}
    ]
  init: ({root, context, pubsub}) ->
    {ldcolor,ldpp,ldCover} = context
    @obj = obj = {evt-handler: {}}
    @itf = itf =
      get: -> obj.pal
      on: (n, cb) -> obj.evt-handler.[][n].push cb
      fire: (n, ...v) -> for cb in (obj.evt-handler[n] or []) => cb.apply @, v
    view = new ldView do
      root: root
      action: click:
        ldp: ->
          obj.ldpp.get!then ->
            if !it => return
            obj.pal = it
            view.render \color
            itf.fire \change, obj.pal
      init: ldcv: ({node}) ->
        obj.ldcv = new ldCover root: node
        obj.ldpp = new ldpp root: node, ldcv: obj.ldcv
        obj.pal = obj.ldpp.ldpe.get-pal!
      handler:
        color:
          list: -> obj.{}pal.[]colors
          key: -> ldcolor.web(it)
          handler: ({node,data}) -> node.style.backgroundColor = ldcolor.web data

  interface: -> @itf

return block-factory