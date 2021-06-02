<-(->it!) _

block-factory =
  pkg:
    name: 'base', version: '0.0.1'
    dependencies: [
      {url: "/assets/lib/ldview/main/ldview.min.js"}
    ]
  init: ({root, context, data, pubsub}) ->
    pubsub.on \init, (opt = {}) ~>
      @itf = itf =
        evt-handler: {}
        get: (opt.get or ->)
        set: (opt.set or ->)
        on: (n, cb) -> @evt-handler.[][n].push cb
        fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
    pubsub.on \event, (n, ...v) ~> @itf.fire.apply @itf, [n] ++ v


  interface: -> @itf

return block-factory
