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
    @obj = obj = {}
    view = new ldView do
      root: root
      action: click: ldp: -> obj.ldcv.get!then -> console.log it
      init: ldcv: ({node}) ->
        obj.ldpp = new ldPalettePicker root: node
        obj.ldcv = new ldCover root: node

  interface: -> {}

return block-factory
