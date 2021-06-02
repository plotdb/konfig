<-(->it!) _

block-factory =
  pkg:
    name: 'choice', version: '0.0.1'
    dependencies: []
  init: ({root, context, data, pubsub}) ->
    @obj = obj = {evt-handler: {}}
    @itf = itf =
      get: -> {} <<< view.get('select').value
      on: (n, cb) -> obj.evt-handler.[][n].push cb
      fire: (n, ...v) -> for cb in (obj.evt-handler[n] or []) => cb.apply @, v
    view = new ldView do
      root: root
      action: change: select: ({node}) -> itf.fire \change, node.value
      handler:
        option:
          list: -> data.values
          key: -> it
          handler: ({node,data}) ->
            node.setAttribute \value, data
            node.textContent = data

  interface: -> @itf

return block-factory
