<-(->it!) _

block-factory =
  pkg:
    name: 'boolean', version: '0.0.1'
    dependencies: []
  init: ({root, context, pubsub}) ->
    @obj = obj = {state: false, evt-handler: {}}
    @itf = itf =
      get: -> obj.state
      on: (n, cb) -> obj.evt-handler.[][n].push cb
      fire: (n, ...v) -> for cb in (obj.evt-handler[n] or []) => cb.apply @, v
    view = new ldView do
      root: root
      action: click:
        switch: ->
          obj.state = !!!obj.state
          view.render \switch
          itf.fire \change, obj.state
      handler:
        switch: ({node}) -> node.classList.toggle \on, obj.state

  interface: -> @itf

return block-factory
