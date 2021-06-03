<-(->it!) _

block-factory =
  pkg:
    name: 'font', version: '0.0.1'
    extend: name: 'base', version: '0.0.1'
    dependencies: [
      {url: "/assets/lib/choosefont.js/main/choosefont.min.js"}
      {url: "/assets/lib/choosefont.js/main/choosefont.min.css", global: true}
      {url: "/assets/lib/ldcover/main/ldcv.min.js"}
      {url: "/assets/lib/ldcover/main/ldcv.min.css"}
    ]
  init: ({root, context, data, pubsub}) ->
    {ldview,ldcover,ChooseFont} = context
    obj = {font: {}}
    pubsub.fire \init, do
      get: -> obj.font
      set: -> obj.fontview.get('input').value = it or ''
    view = new ldview do
      root: root
      init:
        ldcv: ({node}) -> obj.ldcv = new ldCover root: node
        inner: ({node}) ->
          obj.cf = new ChooseFont do
            root: node
            meta-url: '/assets/lib/choosefont.js/main/fontinfo/meta.json'
            base: 'https://plotdb.github.io/xl-fontset/alpha'
          obj.cf.init!then ->
            obj.cf.on \choose, ->
              console.log \ok123
              obj.ldcv.set it
      action: click:
        button: ->
          obj.ldcv.get!then ->
            if !it => return
            obj.font = it
      text: "font-name": -> obj.font.name or 'Font'

return block-factory
