<-(->it!) _

block-factory =
  pkg:
    name: 'color', version: '0.0.1'
    dependencies: [
      {url: "/assets/lib/ldcolor/main/ldcolor.min.js", async: false}
      {url: "/assets/lib/@loadingio/ldcolorpicker/main/ldcp.min.js"}
      # this doesn't work since ldcp instance is outside scoped DOM!
      #{url: "/assets/lib/@loadingio/ldcolorpicker/main/ldcp.min.css"}
    ]
  init: ({root, context, pubsub}) ->
    {ldcolor} = context
    @obj = obj = {color: '#fff', evt-handler: {}}
    @itf = itf =
      get: -> {} <<<  obj.color
      on: (n, cb) -> obj.evt-handler.[][n].push cb
      fire: (n, ...v) -> for cb in (obj.evt-handler[n] or []) => cb.apply @, v
    view = new ldView do
      root: root
      init: color: ({node}) ->
        obj.ldcp = new ldcolorpicker node
        node.style.backgroundColor = ldcolor.web obj.ldcp.get-color!
        obj.ldcp.on \change, ->
          itf.fire \change, it
          node.style.backgroundColor = ldcolor.web it

  interface: -> @itf

return block-factory
