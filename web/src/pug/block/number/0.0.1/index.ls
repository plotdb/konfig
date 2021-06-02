<-(->it!) _

block-factory =
  pkg:
    name: 'number', version: '0.0.1'
    dependencies: [
      {url: "/assets/lib/ldslider/main/ldrs.css", type: \css}
      {url: "/assets/lib/ldslider/main/ldrs.js", async: false}
    ]
  init: ({root, context, pubsub}) ->
    {ldrs} = context
    @obj = obj = {evt-handler: {}}
    @itf = itf =
      get: -> obj.pal
      on: (n, cb) -> obj.evt-handler.[][n].push cb
      fire: (n, ...v) -> for cb in (obj.evt-handler[n] or []) => cb.apply @, v
    view = new ldView do
      root: root
      action: click:
        switch: -> obj.ldrs.edit!
      init: ldrs: ({node}) ->
        obj.ldrs = new ldslider root: node

  interface: -> @itf

return block-factory
